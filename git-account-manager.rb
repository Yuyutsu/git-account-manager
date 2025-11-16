class GitAccountManager < Formula
  desc "Bash script to manage multiple Git accounts (GitHub/GitLab) on a single machine"
  homepage "https://github.com/amolchavan/git-account-manager"
  url "https://github.com/amolchavan/git-account-manager/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "" # Will be calculated after creating the release
  license "MIT"
  version "1.0.0"

  depends_on "git"
  depends_on "openssh"

  def install
    bin.install "git-account-manager.sh" => "git-account-manager"
    doc.install "README.md", "PREREQUISITES.md"
  end

  def caveats
    <<~EOS
      Git Account Manager has been installed!
      
      Run the tool with:
        git-account-manager
      
      For detailed usage instructions:
        cat #{doc}/README.md
      
      Prerequisites check:
        cat #{doc}/PREREQUISITES.md
      
      The tool will manage your SSH configuration at:
        ~/.ssh/config
        ~/.ssh/backup_git_accounts/
    EOS
  end

  test do
    assert_match "MULTI GIT ACCOUNT MANAGER", shell_output("#{bin}/git-account-manager", 1)
  end
end
