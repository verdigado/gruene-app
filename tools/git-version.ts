import { Octokit } from '@octokit/rest'
import { program } from 'commander'

import { VERSION_FILE, tagId } from './constants.js'
import authenticate from './github-authentication.js'
import jsYaml from 'js-yaml'

type TagOptions = {
  versionName: string
  versionCode: number
  owner: string
  repo: string
  commitSha: string
  appOctokit: Octokit
}

const createTag = async ({ versionName, versionCode, owner, repo, commitSha, appOctokit }: TagOptions) => {
  const id = tagId({ versionName })
  const tagMessage = `${versionName} - ${versionCode}`

  const tag = await appOctokit.git.createTag({
    owner,
    repo,
    tag: id,
    message: tagMessage,
    object: commitSha,
    type: 'commit'
  })
  const tagSha = tag.data.sha
  console.warn(`New tag with id ${id} successfully created.`)

  await appOctokit.git.createRef({
    owner,
    repo,
    ref: `refs/tags/${id}`,
    sha: tagSha
  })
  console.warn(`New ref with id ${id} successfully created.`)
}

type Options = {
  githubPrivateKey: string
  owner: string
  repo: string
  branch: string
}
const commitAndTag = async (
  versionName: string,
  versionCodeString: string,
  { githubPrivateKey, owner, repo, branch }: Options
) => {
  const appOctokit = await authenticate({ githubPrivateKey, owner, repo })
  const versionFileContent = await appOctokit.repos.getContent({ owner, repo, path: VERSION_FILE, ref: branch })

  const versionCode = parseInt(versionCodeString, 10)
  if (Number.isNaN(versionCode)) {
    throw new Error(`Failed to parse version code string: ${versionCodeString}`)
  }

  const contentBase64 = Buffer.from(jsYaml.dump({ versionName, versionCode })).toString('base64')

  const commitMessage = `Bump version name to ${versionName} and version code to ${versionCode}\n[skip ci]`

  const commit = await appOctokit.repos.createOrUpdateFileContents({
    owner,
    repo,
    path: VERSION_FILE,
    content: contentBase64,
    branch,
    message: commitMessage,
    // @ts-expect-error Random typescript error: property sha is not available on type { ..., sha: string, ... }
    sha: versionFileContent.data.sha
  })
  console.warn(`New version successfully commited with message "${commitMessage}".`)

  const commitSha = commit.data.commit.sha

  await createTag({
    versionName,
    versionCode,
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    commitSha: commitSha!,
    appOctokit,
    owner,
    repo
  })
}

program
  .command('bump-to <new-version-name> <new-version-code>')
  .description('commits the supplied version name and code to github and tags the commit')
  .requiredOption(
    '--github-private-key <github-private-key>',
    'private key of the github release bot in pem format with base64 encoding'
  )
  .requiredOption('--owner <owner>', 'owner of the current repository, usually verdigado')
  .requiredOption('--repo <repo>', 'the current repository, should be gruene_app')
  .requiredOption('--branch <branch>', 'the current branch')
  .action(async (newVersionName: string, newVersionCode: string, options: Options) => {
    try {
      await commitAndTag(newVersionName, newVersionCode, options)
    } catch (e) {
      console.error(e)
      process.exit(1)
    }
  })

program.parse(process.argv)
