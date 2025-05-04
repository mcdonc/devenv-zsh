Use ZSH as the Default Devenv Shell
-----------------------------------

``devenv-zsh`` changes the interactive shell that launches when you type
``devenv shell`` from ``bash`` to ``zsh``.  It will use your global ZSH
configuration.

To use ``devenv-zsh`` in your devenv config, first import ``zsh.nix`` into your
devenv config, then set the ``zsh.enable`` flag to ``true`` within your
``devenv.nix``.  If ``zsh.enable`` is ``true``, the following extra settings
can be configured:

``zsh.extraInit``
+++++++++++++++++

Commands issued when ZSH starts under devenv.

``zsh.package``
+++++++++++++++

The zsh package to use (default is ``pkgs.zsh``).

Here is an example devenv configuration showing the use of the ``enable`` and
``extraInit`` settings:

.. code-block:: nix

  { pkgs, lib, config, inputs, ... }:
  {
    imports = [ ./path/to/checkout/of/devenv-nix ];
    zsh.enable = true;
    zsh.extraInit = ''
     echo "hello from zsh!"
    '';
    enterShell = ''
     echo "hi from bash!"
    '';
  }

When you run ``devenv shell`` against this configuration, you will see the
following output::

  • Building shell ...
  • Using Cachix: devenv
  ✔ Building shell in 116ms
  • Entering shell ...
  Running tasks     devenv:enterShell
  Succeeded         devenv:enterShell 7ms
  1 Succeeded                         7.94ms
  hi from bash!
  hello from zsh!

And you will be at a ZSH prompt.

Note that:

- ``devenv-zsh`` makes no attempt to modify your prompt to let you know that
  you're inside a devenv, so you'll likely have to use ``extraInit`` to
  configure the prompt differently or edit your global ZSH configuration to add
  to your existing prompt.

  I use Powerlevel within my ZSH configuration to manage my prompt, and I've
  added a function to my ``.p10k.zsh`` that looks like this:

  .. code-block:: zsh

    function my_prompt_devenv() {
      if [ -z "$DEVENV_ROOT" ]; then
        return
      fi
      p10k segment -b 015 -f blue -i $'\uF4E6' -t devenv
    }

  And I've added ``my_prompt_devenv`` to my
  ``POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`` array in the same file.

  It is supposedly possible to do this from outside the .p10k.zsh configuration
  file (and thus within ``extraInit``) but I was unsuccessful when I tried.

- Unlike the default bash that comes with ``devenv``, ``devenv-zsh`` loads your
  global and $HOME configurations of zsh. This is done before it runs the
  ``extraInit``.

- All of the ``enterShell`` logic must still be written in Bash, this project
  only executes zsh after ``enterShell`` completes.

- At the moment ``devenv up`` / ``devenv processes up`` must be run from within
  an existing devenv shell if you use this.
