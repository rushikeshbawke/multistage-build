# Docker Image Runtime Failure - Summary & Analysis

## Root Cause: Build Script Issue

Your image fails to run because **the `dist` folder does not exist in the final stage**. The problem is in your build script:

```json
"build": "cp -r src dist"
```

### Why It Fails:

1. The builder stage runs `npm run build`, which attempts to copy `src/` → `dist/`
2. The final stage copies `dist/` from the builder, but `dist/` is empty because the copy command doesn't exist on Windows
3. PowerShell does not have the `cp` command — that's a Unix/Linux command
4. When the container starts, `node dist/main.js` fails with `MODULE_NOT_FOUND` error
5. The error message: `Error: Cannot find module '/app/dist/main.js'`

---

## What Went Wrong

- **Cross-platform incompatibility**: Your build script uses Unix commands (`cp`) that don't run on Windows
- **No dist folder**: The `dist` folder is never created, so there's nothing to copy to the final stage
- **No validation**: Docker doesn't automatically validate that referenced files exist until runtime
- **Cached builds masked the issue**: Layer caching hid the problem; a fresh build would have failed earlier

---

## Preventative Measures & Best Practices

### 1. Use Cross-Platform Commands in Scripts
Replace shell-specific commands with approaches that work everywhere:
- Use a bundler tool (esbuild, webpack, Vite) instead of shell copy commands
- Use Node.js-based tools for file operations
- Example alternative:
  ```json
  "build": "node -e \"require('fs').cpSync('src', 'dist', {recursive: true})\""
  ```

### 2. Validate Build Output Locally Before Containerizing
- Run `npm run build` in your project root
- Verify that `dist/` exists and contains `main.js`
- Check that all expected files are present

### 3. Test Clean Builds Regularly
- Always test with `docker build --no-cache` to bypass layer caching
- Caching can hide issues that would appear on fresh builds
- Verify that the build works from scratch, not just from cache

### 4. Test the Image Immediately After Building
- Run the image: `docker run -p 3000:3000 <image-name>`
- Check logs: `docker logs <container-id>`
- Don't assume success — catch runtime errors early
- Test the actual functionality, not just that the container starts

### 5. Dockerfile Validation Checklist
- ✅ All COPY commands reference files that exist after the build step
- ✅ Build scripts are cross-platform (Windows + Linux/Mac)
- ✅ Final entry point (CMD) references files that exist in the final stage
- ✅ Multi-stage builds correctly copy artifacts from builder to final stage
- ✅ USER permissions are correctly set for the entry point

### 6. Catch Issues Early in Development
- Use `docker build --progress=plain` for more detailed build output
- Read build logs carefully for warnings
- Test on the same OS where the image will run (or use CI/CD)

---

## Current Setup Issues

| Issue | Impact | Fix |
|-------|--------|-----|
| `cp` command on Windows | `dist/` never created | Use Node.js copy or bundler |
| No local build validation | Runtime failure in container | Run `npm run build` locally first |
| Cached layers | Hidden failures | Test with `--no-cache` |
| No post-build verification | Errors caught too late | Always `docker run` and check logs |

---

## Next Steps

1. Update your `package.json` build script to work cross-platform
2. Test `npm run build` locally and verify `dist/main.js` exists
3. Rebuild the Docker image with `docker build --no-cache -t test-image .`
4. Run and verify: `docker run -p 3000:3000 test-image`
5. Check the container: `docker logs <container-id>`
