## Jekyll Frontmatter Tests

A gem to add tests to your Jekyll site to make sure you're always including required fields on posts or other collection documents.

### Setup

1. For now, create a directory at `deploy/tests/schema` in the root of your jekyll site. This command should do the trick: `mkdir -p deploy/tests/schema`.

    Eventually the plugin will load the location of these schema files from `_config.yml` but for now, the plugin will expect that directory to exist.

2. Create a YAML file in the directory you just created called `_posts.yml`. Add a new line for each required field. If, for example, your site requires posts to have a `title` and `authors` keys, your schema file would look like this:

    ```
    ---
    title: "String"
    authors: "String"
    ```

    The part on the other side of the colon is what "type" of thing we expect the field to be. Right now we only really support "String" and "Array". In that same example, if you're `authors` section in the post looks like this:
    ```
    ---
    title: "Title of the post"
    authors:
    - jane
    - jim
    ```

    You want your schema to look like this:

    ```
    ---
    title: "String"
    authors: "Array"
    ```

    There is an `example.yml` file in this repo to give you a sense of how to structure the file.

    Eventually we want to support the following types:
    - [x] String
    - [x] Array
    - [ ] Date strings
    - [ ] Integers
    - [ ] Complex array validation (possibly through "sub-schema" defined in a "rules.yml" file)

### Flags

`-a` - The default, checks all collections with a schema document at `/deploy/tests/schema`
`-c COLLECTION` - Target a specific collection, for example `jekyll test -c albums` would test any documents in the "albums" collection against a defined schema.
`-p` - Test only posts.

Again, by default `jekyll test` runs with `-a`, the flag is there if you want to be explicit. The other flags are useful if you have a site with many collections and many documents inside them. 18f.gsa.gov for example has hundreds of `_posts` and `_team` documents, running `-c team` generates cleaner results if we're only interested in our "team" documents.

### Contributing

* If it's a bug and you don't want to get messy with Ruby, file an issue!
* If it's a bug you already fixed, fork the repo and open a pull request!
* If you're using it in the wild, file an issue and let us know!
