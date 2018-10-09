#!/bin/bash
git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
mvn clean install deploy scm:tag -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short HEAD) -Dusername=${GIT_USER_NAME} -Dpassword=${GITPW}
