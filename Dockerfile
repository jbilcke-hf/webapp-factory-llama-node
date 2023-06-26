FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
LABEL maintainer="Hugging Face"

ENV PYTHONUNBUFFERED 1

EXPOSE 7860

ARG DEBIAN_FRONTEND=noninteractive

# Use login shell to read variables from `~/.profile` (to pass dynamic created variables between RUN commands)
SHELL ["sh", "-lc"]

RUN apt update

RUN apt --yes install build-essential

RUN apt --yes install curl

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

RUN apt --yes install nodejs

# we need Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y

# configure PNPM

RUN corepack enable
RUN corepack prepare pnpm@6.0.0 --activate

RUN apt --yes install git git-lfs libsndfile1-dev tesseract-ocr espeak-ng python3 python3-pip ffmpeg

RUN git lfs install

RUN python3 -m pip install --no-cache-dir --upgrade pip

RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
	PATH=/home/user/.local/bin:$PATH

WORKDIR $HOME/app

# prepare to install the Node app
COPY --chown=user package*.json .

RUN pnpm install

# ok! let's try to compile llama-node
RUN git clone https://github.com/Atome-FE/llama-node.git

WORKDIR $HOME/app/llama-node

RUN git submodule update --init --recursive

RUN pnpm install --ignore-scripts

WORKDIR $HOME/app/llama-node/packages/llama-cpp

RUN pnpm build:cuda

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$HOME/.llama-node

# ok.. should be good?

COPY --chown=user . .

ADD --chown=user https://huggingface.co/TheBloke/airoboros-13b-gpt4-GGML/resolve/main/airoboros-13b-gpt4.ggmlv3.q4_0.bin models/airoboros-13b-gpt4.ggmlv3.q4_0.bin

RUN python3 test.py

CMD [ "pnpm", "run", "start" ]