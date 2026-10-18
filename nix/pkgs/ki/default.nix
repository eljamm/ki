{
  lib,
  python3,
  anki,

  root,
  version ? "dev",
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ki";
  pyproject = true;
  inherit version;

  # local source directory, filtered to avoid unnecessary rebuilds
  src = lib.cleanSource root;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = [
    anki
  ]
  ++ (with python3.pkgs; [
    beartype
    colorama
    git-filter-repo
    gitpython
    lark
    tqdm
    whatthepatch
  ]);

  nativeCheckInputs = with python3.pkgs; [
    bitstring
    checksumdir
    gitpython
    loguru
    pytest-mock
    pytestCheckHook
  ];

  pythonRelaxDeps = [
    "anki"
    "tqdm"
    "click"
    "beartype"
    "gitpython"
  ];

  disabledTests = [
    # requires git to not be in path, but git is needed for other tests
    "test_clone_cleans_up_on_error"
    "test_clone_clean_up_preserves_directories_that_exist_a_priori"
  ];

  passthru = {
    pyEnv = python3.withPackages (_ps: finalAttrs.passthru.dependencies);
  };

  meta = {
    description = "Version control for Anki collections";
    homepage = "https://github.com/langfield/ki";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ eljamm ];
  };
})
