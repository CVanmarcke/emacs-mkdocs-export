FROM silex/emacs:29.4-alpine

VOLUME /cache

COPY ./config-default /config
COPY ./.emacs.d/ /root/.emacs.d/
RUN ["emacs", "-batch", "-l", "/root/.emacs.d/install-packages.el"]

ENTRYPOINT ["emacs", "-batch", "-l", "/root/.emacs.d/init.el"]
CMD ["--eval=(org-publish-all)"]
