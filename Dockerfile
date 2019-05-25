FROM python:3.7.3
LABEL maintainer="shinn1r0 <github@shinichironaito.com>"

EXPOSE 8888
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HOME /root

RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y

RUN apt-get install -y git

RUN pip install --upgrade pip setuptools pipenv
RUN pip install --upgrade ipython ipyparallel
RUN pip install jupyter jupyter-contrib-nbextensions jupyter-nbextensions-configurator jupyterthemes
RUN pip install jupyter_http_over_ws && jupyter serverextension enable --py jupyter_http_over_ws
RUN pip install isort autopep8

RUN apt-get install curl unzip -y
RUN mkdir -p /usr/share/fonts/opentype/noto
RUN curl -O https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
RUN unzip NotoSansCJKjp-hinted.zip -d /usr/share/fonts/opentype/noto
RUN rm NotoSansCJKjp-hinted.zip
RUN apt-get install fontconfig
RUN fc-cache -f

RUN echo "\nfont.family: Noto Sans CJK JP" >> $(python -c 'import matplotlib as m; print(m.matplotlib_fname())') \
  && rm -f ~/.cache/matplotlib/font*

RUN jupyter contrib nbextension install --user
RUN jupyter nbextensions_configurator enable --user
RUN mkdir -p $(jupyter --data-dir)/nbextensions
RUN git clone https://github.com/lambdalisue/jupyter-vim-binding $(jupyter --data-dir)/nbextensions/vim_binding
RUN jupyter nbextension enable vim_binding/vim_binding
RUN jupyter notebook --generate-config
RUN ipython profile create
RUN jt -t onedork -vim -T -N -ofs 11 -f hack -tfs 11 -cellw 95%

COPY .jupyter/jupyter_notebook_config.py ${HOME}/.jupyter/jupyter_notebook_config.py
RUN cat ${HOME}/.ipython/profile_default/ipython_config.py | sed -e "s/#c.InteractiveShellApp.exec_lines = \[\]/c.InteractiveShellApp.exec_lines = \['%matplotlib inline', 'from jupyterthemes import jtplot', 'jtplot.style()'\]/g" | tee ${HOME}/.ipython/profile_default/ipython_config.py
RUN ipcluster nbextension enable

RUN jupyter nbextension enable toggle_all_line_numbers/main
RUN jupyter nbextension enable code_prettify/code_prettify
RUN jupyter nbextension enable code_prettify/isort
RUN jupyter nbextension enable code_prettify/autopep8
RUN jupyter nbextension enable livemdpreview/livemdpreview
RUN jupyter nbextension enable codefolding/main
RUN jupyter nbextension enable execute_time/ExecuteTime
RUN jupyter nbextension disable hinterland/hinterland
RUN jupyter nbextension enable toc2/main
RUN jupyter nbextension enable varInspector/main
RUN jupyter nbextension enable ruler/main
RUN jupyter nbextension enable latex_envs/latex_envs
RUN jupyter nbextension enable comment-uncomment/main
RUN jupyter nbextension enable scratchpad/main
RUN jupyter nbextension enable gist_it/main
RUN jupyter nbextension enable keyboard_shortcut_editor/main
RUN jupyter nbextension enable hide_input/main
RUN jupyter nbextension enable hide_input_all/main
RUN jupyter nbextension enable table_beautifier/main
RUN jupyter nbextension enable equation-numbering/main
RUN jupyter nbextension enable highlight_selected_word/main
RUN jupyter nbextension enable freeze/main
RUN jupyter nbextension enable snippets/main
RUN jupyter nbextension enable snippets_menu/main
RUN jupyter nbextension enable tree-filter/index
RUN jupyter nbextension enable ruler/edit
RUN jupyter nbextension enable vim_binding/vim_binding

RUN set -ex && mkdir /workspace

WORKDIR /workspace

ENV PYTHONPATH "/workspace"
