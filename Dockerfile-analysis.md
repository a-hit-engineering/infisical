# Infisical Standalone Dockerfile 镜像层分析报告

## 🚨 镜像过大的主要原因

### 1. 重复的系统包安装 (最严重问题)

**问题位置**:

- Line 51-60: backend-build 阶段
- Line 75-84: backend-runner 阶段
- Line 94-106: production 阶段

**影响**: 三次安装相同的依赖包，每次都会增加镜像层

```dockerfile
# 在三个不同阶段重复安装相同的包
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    unixodbc \
    freetds-bin \
    unixodbc-dev \
    libc-dev \
    freetds-dev \
    && rm -rf /var/lib/apt/lists/*
```

### 2. 基础镜像选择不当

**问题**: 使用 `node:20-slim` 但仍需要大量编译工具
**影响**: 需要安装大量的系统依赖

### 3. 不必要的工具安装

**问题位置**: Line 94-106

- `git` - 运行时可能不需要
- `wget` - 可能不是运行时必需
- `openssh-client` - 运行时可能不需要

### 4. 开发依赖未清理

**问题位置**: Line 67

```dockerfile
RUN npm i -D tsconfig-paths  # 开发依赖安装后未清理
```

### 5. npm 缓存未清理

npm 安装后缓存文件未清理，占用额外空间

## 📊 预估层大小分布

1. **基础镜像 (node:20-slim)**: ~180MB
2. **系统包安装** (3 次重复): ~300MB
3. **Node.js 依赖**:
   - Frontend: ~200MB
   - Backend: ~300MB
4. **Infisical CLI**: ~50MB
5. **应用代码**: ~100MB

**总计预估**: ~1.1GB+

## 🛠️ 优化建议 (优先级排序)

### 🔥 高优先级 (立即修复)

1. **合并系统包安装**

   - 只在 production 阶段安装运行时需要的包
   - 移除重复的 apt-get 安装

2. **清理开发依赖**

   - 移除 build 后的开发依赖
   - 清理 npm 缓存

3. **精简运行时依赖**
   - 移除 git、wget 等非必需工具
   - 只保留运行时必需的包

### 🚀 中优先级

4. **使用多阶段构建优化**

   - 更好地利用 build 阶段和运行阶段分离
   - 只复制必要的文件到最终镜像

5. **考虑使用 distroless 镜像**
   - 对于最终运行阶段使用更小的基础镜像

### 💡 低优先级

6. **代码优化**
   - 减少 bundle 大小
   - 移除未使用的依赖

## 🎯 预期优化效果

通过以上优化，预计可以将镜像大小从 **1.1GB+ 减少到 400-600MB**，减少约 **40-50%** 的大小。
