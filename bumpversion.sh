[[ -z "${BUMP_USER}" ]] && BUMP_USER=${GITHUB_ACTOR} || BUMP_USER="${BUMP_USER}"
[[ -z "${BUMP_EMAIL}" ]] && BUMP_EMAIL="${GITHUB_ACTOR}@mackevision.com" || BUMP_EMAIL="${BUMP_EMAIL}"
git config user.name "${BUMP_USER}"
git config user.email "${BUMP_EMAIL}"
git config --global push.followTags true
git remote set-url origin https://${BUMP_user}:${{ secrets.GITHUB_TOKEN }}@github.com/${GITHUB_REPOSITORY}
LAST_COMMIT=$(git log -1 --pretty=%B)
if [ -z "${LAST_COMMIT}" ]; then
echo "no commit message found exiting"
echo "::set-output name=skip::true"
exit 0
fi
if [[ $LAST_COMMIT == *"#major"* ]]; then
BUMP_LEVEL="major"
elif [[ $LAST_COMMIT == *"#minor"* ]]; then
BUMP_LEVEL="minor"
elif [[ $LAST_COMMIT == *"#patch"* ]]; then
BUMP_LEVEL="patch"
fi
if [ -z "${BUMP_LEVEL}" ]; then
echo "PR with no indicator for bumpversion found. Do nothing."
echo "::set-output name=skip::true"
exit
fi
echo "Bump ${BUMP_LEVEL} version"
python -m pip install --upgrade pip
pip install bump2version
python -m bumpversion $BUMP_LEVEL --verbose
git push
git fetch --unshallow
git checkout master
git merge develop
git push
