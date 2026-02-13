# Hugo Static Site Generator Docker Container

A lightweight Docker container for Hugo static site generator with extended features support, built from source.

## Features

- 🏗️ **Built from Source**: Latest Hugo version (v0.155.3) compiled with extended features
- 🔧 **CGO Enabled**: Full support for SCSS/SASS processing and image optimization
- 🚀 **Ubuntu Noble Base**: Stable and secure foundation
- 📦 **Multi-Stage Build**: Optimized image size while retaining full functionality
- 🌐 **Development Ready**: Perfect for local development and CI/CD pipelines

## Quick Start

### Build and Push

```bash
make build
```

### Run Hugo Server (Development)

```bash
# Run Hugo development server
docker run -it --rm \
  -p 1313:1313 \
  -v $(pwd):/src \
  -w /src \
  rossigee/hugo:latest \
  hugo server --bind 0.0.0.0 --baseURL=http://localhost:1313
```

### Build Static Site

```bash
# Build your Hugo site
docker run --rm \
  -v $(pwd):/src \
  -w /src \
  rossigee/hugo:latest \
  hugo
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  hugo:
    image: rossigee/hugo:latest
    ports:
      - "1313:1313"
    volumes:
      - .:/src
    working_dir: /src
    command: hugo server --bind 0.0.0.0 --baseURL=http://localhost:1313
    restart: unless-stopped
```

Then run:

```bash
docker-compose up -d
```

## Common Usage Patterns

### Development Workflow

```bash
# Create new Hugo site
docker run --rm -v $(pwd):/src -w /src rossigee/hugo:latest hugo new site mysite
cd mysite

# Add a theme (example with Ananke)
git init
git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke
echo "theme = 'ananke'" >> hugo.toml

# Create new content
docker run --rm -v $(pwd):/src -w /src rossigee/hugo:latest hugo new posts/my-first-post.md

# Start development server
docker run -p 1313:1313 -v $(pwd):/src -w /src rossigee/hugo:latest \
  hugo server --bind 0.0.0.0 --baseURL=http://localhost:1313 --buildDrafts
```

### Production Build

```bash
# Build optimized site for production
docker run --rm -v $(pwd):/src -w /src rossigee/hugo:latest \
  hugo --minify --gc --cleanDestinationDir

# Build with specific environment
docker run --rm -v $(pwd):/src -w /src rossigee/hugo:latest \
  hugo --environment production --minify
```

### CI/CD Integration

Example GitLab CI configuration:

```yaml
build-site:
  image: rossigee/hugo:latest
  script:
    - hugo --minify --gc
  artifacts:
    paths:
      - public/
  only:
    - master
```

Example GitHub Actions:

```yaml
- name: Build Hugo Site
  run: |
    docker run --rm -v ${{ github.workspace }}:/src -w /src \
      rossigee/hugo:latest hugo --minify --gc
```

## Hugo Version

This container is built with **Hugo v0.155.3** with extended features including:

- SCSS/SASS processing
- PostCSS support
- WebP image processing
- Hugo Modules support
- All built-in shortcodes and functions

## Volume Mounts

- **Source Code**: Mount your Hugo site directory to `/src`
- **Output**: Hugo generates files to `./public/` by default
- **Themes**: Place themes in `./themes/` directory
- **Config**: Hugo configuration files (`hugo.toml`, `config.yaml`, etc.)

## Environment Variables

Hugo respects these environment variables:

- `HUGO_ENV`: Set environment (development, staging, production)
- `HUGO_ENABLEGITINFO`: Enable Git information in pages
- `HUGO_CACHEDIR`: Custom cache directory location

Example with environment variables:

```bash
docker run --rm \
  -e HUGO_ENV=production \
  -e HUGO_ENABLEGITINFO=true \
  -v $(pwd):/src -w /src \
  rossigee/hugo:latest hugo
```

## Building from Source

### Prerequisites

- Docker
- Make (optional)

### Build Commands

```bash
# Using Make
make build

# Using Docker directly
docker build -t rossigee/hugo:latest .
```

### Build Process

The build process uses a multi-stage approach:

1. **Build Stage**: Compiles Hugo from source with Go 1.25.0
2. **Runtime Stage**: Creates minimal runtime image with just the Hugo binary

## Troubleshooting

### Common Issues

**Permission Errors**: Ensure your user has permission to the mounted directory:

```bash
# Fix permissions if needed
docker run --rm -v $(pwd):/src -w /src --user $(id -u):$(id -g) rossigee/hugo:latest hugo
```

**Theme Not Found**: Ensure themes are properly installed:

```bash
# Initialize git submodules
git submodule update --init --recursive
```

**Development Server Not Accessible**: Ensure Hugo server binds to all interfaces:

```bash
hugo server --bind 0.0.0.0 --baseURL=http://localhost:1313
```

## Kubernetes Deployment

Example Kubernetes deployment for Hugo development:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hugo-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hugo-dev
  template:
    metadata:
      labels:
        app: hugo-dev
    spec:
      containers:
      - name: hugo
        image: rossigee/hugo:latest
        command: ["hugo", "server", "--bind", "0.0.0.0", "--appendPort=false"]
        ports:
        - containerPort: 1313
        volumeMounts:
        - name: hugo-content
          mountPath: /src
        workingDir: /src
      volumes:
      - name: hugo-content
        persistentVolumeClaim:
          claimName: hugo-content-pvc
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Test your changes with `make test`
4. Commit your changes
5. Push to the branch
6. Create a Pull Request

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or contributions, please open an issue on the project repository.

Hugo documentation: https://gohugo.io/documentation/
