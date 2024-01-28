FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 as cuda-base
# Set some environment variable for better NVIDIA compatibility
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Use the official Python image as the base image
FROM python:3.9
# set some environment variable for better NVIDIA compatibility
# Copy the necessary files from the CUDA base image
COPY --from=cuda-base /usr/local/cuda /usr/local/cuda
# Set the necessary environment variables
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory to /app
WORKDIR /app
# Copy the inference folder to /app/inference
COPY /inference /app/inference

# Install curl and add the NodeSource repositories
RUN apt-get update && apt-get install -y curl wget ffmpeg unzip 
RUN pip install  -r inference/requirements.txt

# Download AzCopy
RUN wget -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy.tar.gz --strip-components=1

# Move AzCopy to the /usr/bin directory
RUN mv azcopy /usr/bin/

# Download the cloning model
RUN wget https://myshell-public-repo-hosting.s3.amazonaws.com/checkpoints_1226.zip && \
    unzip checkpoints_1226.zip && \
    rm -r checkpoints_1226.zip

WORKDIR /app/inference

ENTRYPOINT /usr/src/chat-ui/run.sh 
