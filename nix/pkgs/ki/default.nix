{
  lib,
  python3Packages,
  anki,

  root,
  version ? "dev",
}:

python3Packages.buildPythonApplication {
  pname = "ki";
  pyproject = true;
  inherit version;

  # local source directory, filtered to avoid unnecessary rebuilds
  src = lib.cleanSource root;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = [
    anki
  ]
  ++ (with python3Packages; [
    beartype
    colorama
    git-filter-repo
    gitpython
    lark
    tqdm
    whatthepatch
  ]);

  nativeCheckInputs = with python3Packages; [
    bitstring
    checksumdir
    gitpython
    loguru
    pytest-mock
    pytestCheckHook
  ];

  disabledTests = [
    # requires git to not be in path, but git is needed for other tests
    "test_clone_cleans_up_on_error"
    "test_clone_clean_up_preserves_directories_that_exist_a_priori"
  ];

  dontCheckRuntimeDeps = true;

  meta = {
    description = "Version control for Anki collections";
    homepage = "https://github.com/langfield/ki";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ eljamm ];
  };
}
