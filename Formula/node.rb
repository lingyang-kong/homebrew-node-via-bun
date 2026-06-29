# frozen_string_literal: true

# Node shim formula backed by Bun
class Node < Formula
  desc "Runs Node.js commands using Bun"
  homepage "https://bun.sh/"
  head "https://github.com/lingyang-kong/homebrew-node-via-bun.git", branch: "main"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  resource "npm-version" do
    url "https://gist.github.com/lingyang-kong/9e2bd7d175670fbea0698e96a6c12960.git", branch: "main"
  end

  def install
    bun_bin = Formula["oven-sh/bun/bun"].opt_bin
    install_shims bun_bin, install_npm_version_script
    chmod 0o755, bin.children
  end

  test do
    node_version = shell_output("#{bin}/node -p process.version").strip
    assert_match(/\Av\d+\.\d+\.\d+/, node_version)
    npm_version = "99.88.77"
    release_index_url = %(data:application/json,[{"version":"#{node_version}","npm":"#{npm_version}"}])

    %w[npm npx].each do |shim|
      assert_equal "#{npm_version}\n",
                   shell_output("NODE_RELEASE_INDEX_URL='#{release_index_url}' #{bin / shim} --version")
    end
  end

  def install_npm_version_script
    resource("npm-version").stage do
      libexec.install "npm-version.js"
    end

    libexec / "npm-version.js"
  end

  def install_shims(bun_bin, npm_version_script)
    bun = bun_bin / "bun"

    {
      "node" => [bun, %("#{bun}" -p process.version)],
      "npm" => [bun, %("#{bun}" "#{npm_version_script}")],
      "npx" => [bun_bin / "bunx", %("#{bun}" "#{npm_version_script}")]
    }.each do |shim, (target, version_command)|
      write_shim shim, target, version_command
    end

    write_corepack_shim
  end

  def write_shim(shim, target, version_command)
    (bin / shim).write <<~SH
      #!/bin/sh
      case "$1" in
      -v|--version)
      	exec #{version_command}
      	;;
      esac

      exec "#{target}" "$@"
    SH
  end

  def write_corepack_shim
    (bin / "corepack").write <<~SH
      #!/bin/sh
      echo "corepack is not provided by the Bun-backed node shim" >&2
      exit 127
    SH
  end
end
