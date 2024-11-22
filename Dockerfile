FROM silex/emacs:29.4-alpine

VOLUME /cache

COPY ./.emacs.d/ /root/.emacs.d/
COPY ./config-default /config
RUN ["emacs", "-batch", "-l", "/root/.emacs.d/install-packages.el"]

ENTRYPOINT ["emacs", "-batch", "-l", "/root/.emacs.d/init.el"]
CMD ["--eval=(org-publish-all)"]
