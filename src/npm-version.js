const releaseVersion = process.version;
const releaseIndexUrl =
	process.env.NODE_RELEASE_INDEX_URL ?? 'https://nodejs.org/dist/index.json';

async function main() {
	const response = await fetch(releaseIndexUrl);

	if (!response.ok) {
		console.error(
			`could not fetch Node release index: ${response.status} ${response.statusText}`,
		);
		process.exit(1);
	}

	const release = (await response.json()).find(
		({ version }) => version === releaseVersion,
	);

	if (!release?.npm) {
		console.error(`could not find npm version for Node ${releaseVersion}`);
		process.exit(1);
	}

	console.log(release.npm);
}

main().catch((error) => {
	console.error(error);
	process.exit(1);
});
