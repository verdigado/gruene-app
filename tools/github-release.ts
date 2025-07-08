import { Octokit } from '@octokit/rest'
import { program } from 'commander'

import { tagId } from './constants.js'
import authenticate from './github-authentication.js'

type Options = {
  githubPrivateKey: string
  owner: string
  repo: string
  productionDelivery: string
}

const getGithubApiUrlForReleaseNotes = (owner: string, repo: string): string =>
  `POST /repos/${owner}/${repo}/releases/generate-notes`

const generateReleaseNotesFromGithubEndpoint = async (
  owner: string,
  repo: string,
  appOctokit: Octokit,
  tagName: string
): Promise<string> => {
  try {
    const response = await appOctokit.request(getGithubApiUrlForReleaseNotes(owner, repo), {
      owner,
      repo,
      tag_name: tagName
    })
    return response.data.body
  } catch (e) {
    throw new Error("Couldn't get release notes")
  }
}

const githubRelease = async (
  newVersionName: string,
  newVersionCode: string,
  { githubPrivateKey, owner, repo, productionDelivery }: Options,
): Promise<void> => {
  const versionCode = parseInt(newVersionCode, 10)
  if (Number.isNaN(versionCode)) {
    throw new Error(`Failed to parse version code string: ${newVersionCode}`)
  }

  const releaseName = `${newVersionName} - ${versionCode}`
  const tagName = tagId({ versionName: newVersionName })
  const appOctokit = await authenticate({ githubPrivateKey, owner, repo })

  const release = await appOctokit.repos.createRelease({
    owner,
    repo,
    tag_name: tagName,
    prerelease: productionDelivery === 'false',
    make_latest: productionDelivery === 'true' ? 'true' : 'false',
    name: releaseName,
    body: await generateReleaseNotesFromGithubEndpoint(owner, repo, appOctokit, tagName),
  })
  console.log(release.data.id)
}

program
  .command('create <new-version-name> <new-version-code>')
  .description('creates a new release')
  .requiredOption(
    '--github-private-key <github-private-key>',
    'private key of the github release bot in pem format with base64 encoding',
  )
  .requiredOption('--owner <owner>', 'owner of the current repository, usually verdigado')
  .requiredOption('--repo <repo>', 'the current repository, should be gruene-app')
  .requiredOption('--production-delivery <production-delivery>', 'whether this is a production delivery or not')
  .action(async (newVersionName: string, newVersionCode: string, options: Options) => {
    try {
      await githubRelease(newVersionName, newVersionCode, options)
    } catch (e) {
      console.error(e)
      process.exit(1)
    }
  })

program.parse(process.argv)
