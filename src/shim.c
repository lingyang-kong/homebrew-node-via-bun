#include <stdio.h>
#include <string.h>
#include <unistd.h>

#ifndef BUN_PATH
#error "BUN_PATH must be defined"
#endif

#ifndef BUNX_PATH
#error "BUNX_PATH must be defined"
#endif

#ifndef NPM_VERSION_PATH
#error "NPM_VERSION_PATH must be defined"
#endif

struct applet {
	const char *name, *target;
	enum { NODE, NPM } version;
};

static const struct applet applets[] = {
    {"node", BUN_PATH, NODE},
    {"npm", BUN_PATH, NPM},
    {"npx", BUNX_PATH, NPM},
};

static const char *base_name(const char *path)
{
	const char *slash = strrchr(path, '/');

	return slash ? slash + 1 : path;
}

static const struct applet *find_applet(const char *name)
{
	const size_t n = sizeof(applets) / sizeof(applets[0]);
	for (size_t i = 0; i < n; ++i)
		if (!strcmp(name, applets[i].name))
			return &applets[i];

	return NULL;
}

static int is_version_arg(const char *arg)
{
	return !strcmp(arg, "-v") || !strcmp(arg, "--version");
}

static int exec_or_die(const char *path, char *args[])
{
	execv(path, args);
	perror(path);
	return 127;
}

static int run_version_command(const struct applet *applet)
{
	char *args[4] = {BUN_PATH};

	switch (applet->version) {
	case NODE:
		args[1] = "--print", args[2] = "process.version";
		break;
	case NPM:
		args[1] = NPM_VERSION_PATH, args[2] = NULL;
		break;
	default:
		fprintf(stderr, "%s: invalid version mode\n", applet->name);
		return 127;
	}

	args[3] = NULL;

	return exec_or_die(BUN_PATH, args);
}

static int run_target_command(const struct applet *applet, char *argv[])
{
	argv[0] = (char *)applet->target;

	return exec_or_die(applet->target, argv);
}

int main(int argc, char *argv[])
{
	const char *name = base_name(argv[0]);
	const struct applet *applet = find_applet(name);

	if (!applet) {
		fprintf(stderr, "%s: unknown applet\n", name);
		return 127;
	}

	if (argc > 1 && is_version_arg(argv[1]))
		return run_version_command(applet);

	return run_target_command(applet, argv);
}
