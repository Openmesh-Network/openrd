PROJECT_ROOT = ..
SMARTCONTRACT_FOLDER = src
SOLDITY_VERSION = 0.8.23
TRANSACTION_LIMIT = 3
TIMEOUT = 600

# For Python projects
# On Windows, venv scripts/shims are under `Scripts` instead of `bin`.
VENV_FOLDER := bin
ifeq ($(OS),Windows_NT)
	VENV_FOLDER := Scripts
endif

# Mythril only works on a single file, could run it on all files in src, but it's slowwwww
all:
	${MAKE} slither || true
	# ${MAKE} mythril || true
.PHONY: all

# Slither
VENV_SLITHER = slither
$(VENV_SLITHER)/pyvenv.cfg:
	# Create our Python 3 virtual environment
	python3 -m venv ${VENV_SLITHER}
	$(VENV_SLITHER)/${VENV_FOLDER}/python -m pip install --upgrade pip
	$(VENV_SLITHER)/${VENV_FOLDER}/python -m pip install slither-analyzer

slither: $(VENV_SLITHER)/pyvenv.cfg
	. ./${VENV_SLITHER}/${VENV_FOLDER}/activate && slither ${PROJECT_ROOT} --config-file ${PROJECT_ROOT}/slither.config.json
.PHONY: slither

# Mythril
VENV_MYTHRIL = mythril
$(VENV_MYTHRIL)/pyvenv.cfg:
	# Create our Python 3 virtual environment
	python3 -m venv ${VENV_MYTHRIL}
	$(VENV_MYTHRIL)/${VENV_FOLDER}/python -m pip install --upgrade pip
	$(VENV_MYTHRIL)/${VENV_FOLDER}/python -m pip install mythril

mythril: $(VENV_MYTHRIL)/pyvenv.cfg
	. ./${VENV_MYTHRIL}/${VENV_FOLDER}/activate && myth analyze ${PROJECT_ROOT}/${SMARTCONTRACT_FOLDER}/${TARGET} --solv ${SOLDITY_VERSION} -t ${TRANSACTION_LIMIT} --execution-timeout ${TIMEOUT}
.PHONY: mythril
