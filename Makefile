# Import .env variables if the file exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

deploy:
	${MAKE} --directory=./web3webdeploy deploy
.PHONY: deploy

# Sends 100 ETH to ADDRESS (example usage: make local-fund ADDRESS="0xaF7E68bCb2Fc7295492A00177f14F59B92814e70")
local-fund:
	cast send --value 100000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 ${ADDRESS}
.PHONY: local-fund

# Update all submodules to the latest version (as specified by the branch in .gitmodules, otherwise latest of default branch)
# It will then checkout any updates done to submodules in those projects (but will not update them to the latest remote version, just the commit specified in the project itself).
update:
	git submodule update --remote
	git submodule foreach "git submodule update --init --recursive --checkout"
	${MAKE} clean
.PHONY: update

# Discard any commits/updates done to submodules
revert-submodules:
	git submodule deinit -f .
	git submodule update --init --recursive --checkout
.PHONY: revert-submodules

# Add all commits made since our last update (1 version == 1 commit)
# Gets the latest (newest version - our version) commits of the template
template-update:
	git remote add template https://github.com/Plopmenz/foundry-template.git
	git fetch template
	git show template/main:template.version > newest.version
	git cherry-pick --no-commit template/main~$$(expr $$(cat newest.version) - $$(cat template.version) - 1) template/main || true
	rm newest.version
	git remote remove template
	${MAKE} clean
.PHONY: template-update

# Merge without preference in merge conflicts
template-update-fromstart:
	git remote add template https://github.com/Plopmenz/foundry-template.git
	git fetch template
	git merge template/main --squash --allow-unrelated-histories || true
	git remote remove template
.PHONY: template-update-fromstart

# Remove the template example files
empty:
	rm -rf deploy/counters/Counter.ts
	rm -rf deploy/counters/ProxyCounter.ts
	rm -rf deploy/counters/SetInitialCounterValue.ts
	rmdir deploy/counters || true

	rm -rf src/Counter.sol
	rm -rf src/ProxyCounter.sol

	rm -rf test/Counter.t.sol
	rm -rf test/ProxyCounter.t.sol
.PHONY: empty

# Clean cache and artifacts
# Ideally these also take the configuration in consideration
clean:
	rm -rf ./web3webdeploy/.next 
	rm -rf ./web3webdeploy/node_modules
	rm -rf cache
	rm -rf out
.PHONY: clean

# Analyzers
analyze:
	${MAKE}  --directory=./analyzers all
.PHONY: analyze

slither:
	${MAKE}  --directory=./analyzers slither
.PHONY: slither

mythril:
	${MAKE}  --directory=./analyzers mythril
.PHONY: mythril