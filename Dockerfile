FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
LABEL maintainer="Hugging Face"

ENV PYTHONUNBUFFERED 1

EXPOSE 7860

ARG DEBIAN_FRONTEND=noninteractive

# Use login shell to read variables from `~/.profile` (to pass dynamic created variables between RUN commands)
SHELL ["sh", "-lc"]

RUN apt update

RUN apt --yes install curl

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

RUN apt --yes install nodejs

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

RUN npm install


# OK, now the hell begins.. we need to build llama-node with CUDA support


# we need Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# we need PNP
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

# we also need this (not sure we need musl-tools as it is for cross-compilation)
RUN apt --yes install build-essential musl-tools

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

CMD [ "npm", "run", "start" ]