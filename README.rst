Use ZSH as the Default Devenv Shell
-----------------------------------

``devenv-zsh`` changes the interactive shell that launches when you type
``devenv shell`` from ``bash`` to ``zsh``.  It will use your global ZSH
configuration.  It is hacky but useful until Devenv grows native support for
alternate interactive shells.

Usage
-----

To use ``devenv-zsh`` in your devenv config, first import into into your devenv
config, then set the ``zsh.enable`` flag to ``true`` within your
``devenv.nix``.

Here is an example devenv configuration showing the use of the ``enable`` and
``extraInit`` settings.

Add an input into ``devenv.yaml``::

  devenv-zsh:
    url: github:mcdonc/devenv-zsh

Then in ``devenv.nix``, enable and configure the plugin:

.. code-block:: nix

  { pkgs, lib, config, inputs, devenv-zsh, ... }:
  {
    imports = [ devenv-zsh.plugin ];
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

Settings
--------

If ``zsh.enable`` is ``true``, the following extra settings
can be configured:

``zsh.extraInit``
+++++++++++++++++

Commands issued under ZSH when devenv starts it.

``zsh.package``
+++++++++++++++

The zsh package to use (default is ``pkgs.zsh``).

Notes
-----

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

  It looks like this when I'm in a devenv shell:

  .. image:: http://bouncer.repoze.org/devenvzsh.png
     :alt: Prompt changes

  It is supposedly possible to do this from outside the .p10k.zsh configuration
  file (and thus within ``extraInit``) but I was unsuccessful when I tried.

- Unlike the default bash that comes with ``devenv``, ``devenv-zsh`` loads your
  global and $HOME configurations of zsh. This is done before it runs the
  ``extraInit``.

- All of your ``enterShell`` logic must still be written in Bash, this project
  only executes zsh after ``enterShell`` completes.

- If the environment variable ``DEVENV_ZSH_DISABLE`` is set to a nonempty
  string that is not "0" before you invoke ``devenv shell`` or you cause it to
  be exported anywhere within your project's ``enterShell``, ZSH will not be
  exec'ed even if ``zsh.enable`` is true.

- If there is an error in your devenv's ``enterShell``, ZSH will not be
  launched; you will be using Bash until you fix the error.

- This project makes use of Roman Perepelitsa's ``zshi``
  (https://github.com/romkatv/zshi).
  
Problems (all fixed under devenv 1.7+)
--------------------------------------

- At the moment ``devenv up`` / ``devenv processes up`` must be run from within
  an existing devenv shell or you must set ``DEVENV_ZSH_DISABLE`` before
  invoking either outside of a devenv shell, e.g.
  ``DEVENV_ZSH_DISABLE=1 devenv up``.

- If you invoke ``devenv shell`` from within an existing Devenv shell, the
  subshell will be Bash.

- If you launch Bash from within ZSH via ``bash``, you will likely be
  executing the non-interactive build of Bash and you will see warnings such as
  ``bash: shopt: progcomp: invalid shell option name``, your prompt will be
  messed up, and your movement keys won't work.  To avoid this, add
  ``pkgs.bashInteractive`` to your devenv ``packages``.
