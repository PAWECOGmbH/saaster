FROM docker:27.5.1-cli@sha256:851f91d241214e7c6db86513b270d58776379aacc5eb9c4a87e5b47115e3065c
RUN apk add --no-cache 'borgbackup<2' bash coreutils findutils util-linux rsync python3 openssh-client
ENTRYPOINT ["bash"]
