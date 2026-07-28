import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const projectRoot = path.resolve(
	path.dirname(fileURLToPath(import.meta.url)),
	"..",
);
const sourceDir = path.join(projectRoot, "public", "assets", "images", "logos");
const outputDir = path.join(sourceDir, "transparent");

const logos = {
	cacti: "cacti.jpg",
	cisco: "cisco.png",
	elasticsearch: "elasticsearch.webp",
	fortigate: "fortigate.webp",
	git: "git.webp",
	grafana: "grafana.webp",
	h3c: "h3c.jpg",
	hillstone: "hillstone.jpg",
	huawei: "huawei.jfif",
	linux: "linux.jpg",
	netbox: "netbox.webp",
	nvidia: "nvidia.webp",
	prometheus: "prometheus.png",
	python: "python.png",
	zabbix: "zabbix.webp",
};

const isBackground = (data, offset) => {
	const alpha = data[offset + 3];
	if (alpha <= 8) return true;

	const red = data[offset];
	const green = data[offset + 1];
	const blue = data[offset + 2];
	const brightest = Math.max(red, green, blue);
	const darkest = Math.min(red, green, blue);

	return darkest >= 236 && brightest - darkest <= 16;
};

const removeEdgeConnectedBackground = (data, width, height) => {
	const visited = new Uint8Array(width * height);
	const queue = new Int32Array(width * height);
	let head = 0;
	let tail = 0;

	const enqueue = (x, y) => {
		const pixelIndex = y * width + x;
		if (visited[pixelIndex]) return;
		const offset = pixelIndex * 4;
		if (!isBackground(data, offset)) return;
		visited[pixelIndex] = 1;
		queue[tail++] = pixelIndex;
	};

	for (let x = 0; x < width; x += 1) {
		enqueue(x, 0);
		enqueue(x, height - 1);
	}
	for (let y = 1; y < height - 1; y += 1) {
		enqueue(0, y);
		enqueue(width - 1, y);
	}

	while (head < tail) {
		const pixelIndex = queue[head++];
		const x = pixelIndex % width;
		const y = Math.floor(pixelIndex / width);
		data[pixelIndex * 4 + 3] = 0;

		if (x > 0) enqueue(x - 1, y);
		if (x + 1 < width) enqueue(x + 1, y);
		if (y > 0) enqueue(x, y - 1);
		if (y + 1 < height) enqueue(x, y + 1);
	}
};

const removeNeutralBackground = (data) => {
	for (let offset = 0; offset < data.length; offset += 4) {
		const red = data[offset];
		const green = data[offset + 1];
		const blue = data[offset + 2];
		const chroma = Math.max(red, green, blue) - Math.min(red, green, blue);

		if (chroma <= 18) {
			data[offset + 3] = 0;
		} else if (chroma < 46) {
			data[offset + 3] = Math.round(data[offset + 3] * ((chroma - 18) / 28));
		}
	}
};

const getVisibleBounds = (data, width, height) => {
	let left = width;
	let top = height;
	let right = -1;
	let bottom = -1;

	for (let y = 0; y < height; y += 1) {
		for (let x = 0; x < width; x += 1) {
			if (data[(y * width + x) * 4 + 3] <= 8) continue;
			left = Math.min(left, x);
			top = Math.min(top, y);
			right = Math.max(right, x);
			bottom = Math.max(bottom, y);
		}
	}

	if (right < left || bottom < top) return null;

	return {
		left,
		top,
		width: right - left + 1,
		height: bottom - top + 1,
	};
};

await fs.mkdir(outputDir, { recursive: true });

for (const [name, filename] of Object.entries(logos)) {
	const inputPath = path.join(sourceDir, filename);
	const { data, info } = await sharp(inputPath)
		.ensureAlpha()
		.raw()
		.toBuffer({ resolveWithObject: true });

	removeEdgeConnectedBackground(data, info.width, info.height);

	if (name === "grafana") {
		removeNeutralBackground(data);
	}

	const bounds = getVisibleBounds(data, info.width, info.height);
	let pipeline = sharp(data, {
		raw: {
			width: info.width,
			height: info.height,
			channels: 4,
		},
	});

	if (bounds) {
		pipeline = pipeline.extract(bounds);
	}

	await pipeline
		.png({ compressionLevel: 9 })
		.toFile(path.join(outputDir, `${name}.png`));
}

console.log(`Extracted ${Object.keys(logos).length} transparent logo assets.`);
