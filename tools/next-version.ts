import { program } from 'commander'
import { load } from 'js-yaml'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

import { VERSION_FILE } from './constants.js'

const __dirname = fileURLToPath(new URL('.', import.meta.url))

const calculateNewVersion = () => {
  const versions = load(fs.readFileSync(path.resolve(__dirname, '..', VERSION_FILE), 'utf-8'))
  const { versionCode, versionName } = versions as { versionCode: unknown, versionName: string }
  const versionNameParts = versionName.split('.').map((it: string) => parseInt(it, 10))

  if (typeof versionCode !== 'number') {
    throw new Error(`Version code must be a number, but is of type ${typeof versionCode}.`)
  }

  const date = new Date()
  const year = date.getFullYear()
  const month = date.getMonth() + 1

  const versionNameCounter = year === versionNameParts[0] && month === versionNameParts[1] ? versionNameParts[2]! + 1 : 0
  const newVersionName = `${year}.${month}.${versionNameCounter}`

  const newVersionCode = versionCode ? versionCode + 1 : undefined

  return {
    versionName: newVersionName,
    versionCode: newVersionCode
  }
}

program
  .command('calc')
  .description('calculate the next version')
  .action(() => {
    try {
      const newVersion = calculateNewVersion()

      // Log stringified version to enable bash piping
      console.log(JSON.stringify(newVersion))
    } catch (e) {
      console.error(e)
      process.exit(1)
    }
  })

program.parse(process.argv)
