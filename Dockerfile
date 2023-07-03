FROM mambaorg/micromamba:1.4.6
COPY --chown=$MAMBA_USER:$MAMBA_USER micromamba.yml /tmp/micromamba.yml
RUN micromamba create -f /tmp/micromamba.yml && \
    micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1
