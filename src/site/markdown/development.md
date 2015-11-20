# Development notes

## set up Maven

Install Maven 3.0.5 or newer.

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

Use the regular maven relase cycle; `mvn release:prepare` and then `mvn release:perform`.

## generating and deploying site

`mvn site` will create a staged maven site, `mvn site site:stage site:deploy` should take
care of deploying the site to https://b3partners.github.io/flamingo-ibis/.
