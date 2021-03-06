#!/bin/bash -xe

# Temp version
VERSION="XXX"


reset_to_latest_tag() {
    # Wipe tags
    git tag -l | xargs git tag -d || return 1

    # Add the origin remote if it is not present
    if ! git remote get-url release; then
        git remote add release git@github.com:box/box-annotations.git || return 1
    fi

    # Fetch latest code with tags
    git fetch --tags release || return 1;

    # Remove old local tags in case a build failed
    git fetch --prune release '+refs/tags/*:refs/tags/*' || exit 1
    git clean -fd || return 1
}

install_dependencies() {
    echo "--------------------------------------------------------"
    echo "Installing all package dependencies"
    echo "--------------------------------------------------------"
    if yarn install; then
        echo "----------------------------------------------------"
        echo "Installed dependencies successfully."
        echo "----------------------------------------------------"
    else
        echo "----------------------------------------------------"
        echo "Error: Failed to run 'yarn install'!"
        echo "----------------------------------------------------"
        exit 1;
    fi
}

lint_and_test() {
    echo "----------------------------------------------------"
    echo "Running linter for version" $VERSION
    echo "----------------------------------------------------"
    if yarn lint; then
        echo "----------------------------------------------------"
        echo "Done linting for version" $VERSION
        echo "----------------------------------------------------"
    else
        echo "----------------------------------------------------"
        echo "Failed linting!"
        echo "----------------------------------------------------"
        exit 1;
    fi


    echo "----------------------------------------------------"
    echo "Running flow for version" $VERSION
    echo "----------------------------------------------------"
    if yarn flow check; then
        echo "----------------------------------------------------"
        echo "Done flowing for version" $VERSION
        echo "----------------------------------------------------"
    else
        echo "----------------------------------------------------"
        echo "Failed flowing!"
        echo "----------------------------------------------------"
        exit 1;
    fi


    echo "----------------------------------------------------"
    echo "Running tests for version" $VERSION
    echo "----------------------------------------------------"
    if yarn test; then
        echo "----------------------------------------------------"
        echo "Done testing for version" $VERSION
        echo "----------------------------------------------------"
    else
        echo "----------------------------------------------------"
        echo "Failed testing!"
        echo "----------------------------------------------------"
        exit 1;
    fi
}

clean_assets() {
    echo "----------------------------------------------------"
    echo "Running clean for version" $VERSION
    echo "----------------------------------------------------"
    if yarn clean; then
        echo "----------------------------------------------------"
        echo "Done cleaning for version" $VERSION
        echo "----------------------------------------------------"
    else
        echo "----------------------------------------------------"
        echo "Failed cleaning!"
        echo "----------------------------------------------------"
        exit 1;
    fi
}

build_assets() {
    yarn setup;

    echo "----------------------------------------------------"
    echo "Starting babel build for version" $VERSION
    echo "----------------------------------------------------"
    if yarn build; then
        echo "----------------------------------------------------"
        echo "Built babel assets for version" $VERSION
        echo "----------------------------------------------------"
    else
        echo "----------------------------------------------------"
        echo "Failed to build production assets!"
        echo "----------------------------------------------------"
        exit 1;
    fi
}

push_to_npm() {
    echo "---------------------------------------------------------"
    echo "Running npm publish for version" $VERSION
    echo "---------------------------------------------------------"
    if npm publish; then
        echo "--------------------------------------------------------"
        echo "Published version" $VERSION
        echo "--------------------------------------------------------"
    else
        echo "----------------------------------------------------"
        echo "Error publishing to npm registry!"
        echo "----------------------------------------------------"
        exit 1;
    fi
}

publish_to_npm() {
    if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]] ; then
        echo "----------------------------------------------------"
        echo "Your branch is dirty!"
        echo "----------------------------------------------------"
        exit 1
    fi

    if ! reset_to_latest_tag ; then
        echo "----------------------------------------------------"
        echo "Error in reset_to_latest_tag!"
        echo "----------------------------------------------------"
    fi

    # The current version being published
    VERSION=$(./scripts/current_version.sh)

    if [[ $(git status --porcelain 2>/dev/null| grep "^??") != "" ]] ; then
        echo "----------------------------------------------------"
        echo "Your branch has untracked files!"
        echo "----------------------------------------------------"
        exit 1
    fi

    echo "----------------------------------------------------"
    echo "Checking out version" $VERSION
    echo "----------------------------------------------------"
    # Check out the version we want to build (version tags are prefixed with a v)
    git checkout v$VERSION || exit 1

    # Install node modules
    if ! install_dependencies; then
        echo "----------------------------------------------------"
        echo "Error in install_dependencies!"
        echo "----------------------------------------------------"
        exit 1
    fi

    # Do testing and linting
    if ! clean_assets; then
        echo "----------------------------------------------------"
        echo "Error in clean_assets!"
        echo "----------------------------------------------------"
        exit 1
    fi

    # Do testing and linting
    if ! lint_and_test; then
        echo "----------------------------------------------------"
        echo "Error in lint_and_test!"
        echo "----------------------------------------------------"
        exit 1
    fi

    # Babel build
    if ! build_assets; then
        echo "----------------------------------------------------"
        echo "Error in build_assets!"
        echo "----------------------------------------------------"
        exit 1
    fi

    # Publish
    if ! push_to_npm; then
        echo "----------------------------------------------------"
        echo "Error in push_to_npm!"
        echo "----------------------------------------------------"
        exit 1
    fi
}


# Execute this entire script
if ! publish_to_npm; then
    echo "----------------------------------------------------"
    echo "Error: failure in publish_to_npm!"
    echo "----------------------------------------------------"
    exit 1
fi


echo "----------------------------------------------------"
echo "Checking out back to master"
echo "----------------------------------------------------"
git checkout master || exit 1
