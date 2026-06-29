# frozen_string_literal: true

# Node shim formula backed by Bun
class Node < Formula
  desc "Runs Node.js commands using Bun"
  homepage "https://bun.sh/"
  license "MIT"
  head "https://github.com/lingyang-kong/homebrew-node-via-bun.git", branch: "main"

  depends_on "oven-sh/bun/bun"

  def install
    shim_path = libexec / "node-via-bun"

    libexec.install buildpath / "src/npm-version.js"
    compile_shim(libexec / "npm-version.js", shim_path)
    link_applets(shim_path)
  end

  def compile_shim(npm_version_path, shim_path)
    bun_opt_bin = formula_opt_bin("oven-sh/bun/bun")
    cflags = (buildpath / "src/compile_flags.txt").read.lines.map(&:strip).reject(&:empty?)
    defines = %W[
      -DBUN_PATH="#{bun_opt_bin}/bun"
      -DBUNX_PATH="#{bun_opt_bin}/bunx"
      -DNPM_VERSION_PATH="#{npm_version_path}"
    ]

    system ENV.cc, *cflags, *defines,
           buildpath / "src/shim.c", "--output", shim_path, "-Wl,-dead_strip"
  end

  def link_applets(shim_path)
    bin.mkpath
    %w[node npm npx].each do |name|
      ln shim_path, bin / name
    end
  end

  test do
    node_version = shell_output("#{bin}/node --print process.version").strip
    assert_match(/\Av\d+\.\d+\.\d+/, node_version)
    npm_version = "99.88.77"
    release_index_url = %Q(data:application/json,[{"version":"#{node_version}","npm":"#{npm_version}"}])

    %w[npm npx].each do |shim|
      assert_equal "#{npm_version}\n",
                   shell_output("NODE_RELEASE_INDEX_URL='#{release_index_url}' #{bin / shim} --version")
    end
  end
end
