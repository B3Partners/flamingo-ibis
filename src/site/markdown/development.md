# Development notes

## set up Maven

Install Maven 3.2.5 or newer.

In your maven settings.xml add the following `server` element:

```xml
      <server>
          <id>gh-pages</id>
          <!--<username>git</username>-->
          <password>....</password>
      </server>
```

This is required to publish the site into the gh-pages branch using the
[wagon-git](https://github.com/trajano/wagon-git).

## building

`mvn install` will generate the artifacts for viewer and viewer-admin.

## releasing

Use the regular maven release cycle; `mvn release:prepare` and then `mvn release:perform`. eg.

```
mvn clean
mvn release:prepare -l rel-prepare.log -DautoVersionSubmodules=true -DdevelopmentVersion=2.12-SNAPSHOT -DreleaseVersion=2.11 -Dtag=ibis-flamingo-mc-2.11 -e -T1
mvn release:perform -l rel-perform.log -e -T1
```

To (re-)create the maven site of this tag:

```
git checkout ibis-flamingo-mc-2.11
mvn site-deploy
git checkout master
```

Upload the `dist` artifact to the github release page using the web interface.


## generating and deploying site

`mvn site` will create a staged maven site, `mvn site-deploy` should take
care of deploying the site to https://b3partners.github.io/flamingo-ibis/.
