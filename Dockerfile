FROM rust:latest as builder
RUN rustup target add wasm32-unknown-unknown
RUN wget -qO- https://github.com/thedodd/trunk/releases/download/v0.16.0/trunk-x86_64-unknown-linux-gnu.tar.gz | tar -xzf-
RUN mv trunk /bin/trunk

WORKDIR /bench
# Copy tomls first to cache dependencies
COPY Cargo.* .
COPY src/ ./src
COPY backend/ ./backend
COPY frontend/ ./frontend

RUN cargo build -rp backend
RUN trunk build --release -d web frontend/index.html

FROM ubuntu:latest
COPY --from=builder /bench/target/release/backend /bin/backend
COPY --from=builder /bench/web ./web

CMD ["backend"]