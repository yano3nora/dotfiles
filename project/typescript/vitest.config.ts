import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vitest/config'

// tsconfig の paths "@/*" -> "./*" を Vitest 側でも解決させるための alias。
// Vite/Vitest は tsconfig の `paths` を自動では解決しないため明示する。
// `^@/` で限定し、`@chakra-ui` 等のスコープ付きパッケージへの誤マッチを防ぐ。
// project で `@/*` alias を使わない場合は、この resolve 設定ごと削除してよい。
const root = dirname(fileURLToPath(import.meta.url))

export default defineConfig({
  resolve: {
    alias: [{ find: /^@\//, replacement: resolve(root, '.') + '/' }],
  },
})
