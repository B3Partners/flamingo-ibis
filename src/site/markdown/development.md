# Development notes

<!-- MACRO{toc|section=0|fromDepth=1|toDepth=2} -->

## set up Maven

Install Maven 3.3.9 or newer.

In your maven settings.xml add the following `server` element:

```xml
      <server>
          <id>gh-pages</id>
          <password>SSH PASSPHRASE</password>
      </server>
```

This is required to publish the site into the gh-pages branch using the
maven-scm-publish-plugin.

## building

`mvn install` will generate the artifacts for viewer and viewer-admin.

## releasing

Use the regular maven release cycle; `mvn release:prepare` and then `mvn release:perform`. eg.

```
mvn clean
mvn release:prepare -l rel-prepare.log -DautoVersionSubmodules=true -DdevelopmentVersion=3.1-SNAPSHOT -DreleaseVersion=3.0 -Dtag=ibis-flamingo-mc-3.0 -e -T1
mvn release:perform -l rel-perform.log -e -T1
```

Don't forget to update the release notes.
To (re-)create the maven site of this tag (normally the site is deployed as part of the release procedure):

```
git checkout ibis-flamingo-mc-3.0
mvn -T1 site site:stage
mvn scm-publish:publish-scm
git checkout master
```

Upload the `dist` artifact to the github release page using the web interface.


## generating and deploying site

`mvn site` will create a staged maven site, `mvn site-deploy` should take
care of deploying the site to https://b3partners.github.io/flamingo-ibis/.
