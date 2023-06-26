---
title: Webapp Factory llama-node
emoji: 🏭🦙
colorFrom: brown
colorTo: red
sdk: docker
pinned: false
app_port: 7860
---

A minimalist Docker project to generate apps on demand.

Ready to be used in a Hugging Face Space.

# Examples

## Local prompt examples

```
http://localhost:7860/?prompt=a%20pong%20game%20clone%20in%20HTML,%20made%20using%20the%20canvas
```
```
http://localhost:7860/?prompt=a simple html canvas game where we need to feed tadpoles controlled by an AI. The tadpoles move randomly, but when the user click inside the canvas to add some kind of food, the tadpoles will compete to eat it. Tadpole who didn't eat will die, and those who ate will reproduce.
```

## Installation

### Prerequisites

**A powerful machine is required! You need at least 24 Gb of memory!**

- Install NVM: https://github.com/nvm-sh/nvm
- Install Docker https://www.docker.com

### Download the model

```
cd models
wget ADD https://huggingface.co/TheBloke/airoboros-13b-gpt4-GGML/resolve/main/airoboros-13b-gpt4.ggmlv3.q4_0.bin
```

Note: the Dockerfile script will do this automatically

### Building and run without Docker

```bash
nvm use
npm i
npm run start
```

### Building and running with Docker

```bash
npm run docker
```

This script is a shortcut executing the following commands:

```bash
docker build -t webapp-factory-llama-node .
docker run -it -p 7860:7860 webapp-factory-llama-node
```

### Deployment to Hugging Face

The standard free CPU instance (16 Gb) will not be enough for this project, you should use the upgraded CPU instance (32 Gb)

