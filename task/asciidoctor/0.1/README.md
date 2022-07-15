# Asciidoctor

Tekton Task for Asciidoctor https://asciidoctor.org

Asciidoctor is a fast, open source, Ruby-based text processor for parsing AsciiDoc into a document model and converting it to output formats such as HTML 5, DocBook 5, manual pages, PDF, EPUB 3, and other formats.

The resulting document can be sent by email, uploaded to the artifact repository, etc. through other tasks.

## Install the Task
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/asciidoctor/0.1/raw
```

## Pre-requisite
Install git-clone task from catalog
```
https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.3/raw
```

## Workspaces
* **source** : A Workspace containing your source directory.

## Parameters
* **ASCIIDOC_CMD**: Default ```asciidoctor-pdf```. Command to convert AsciiDoc files :
  * **asciidoctor**: Basic CLI [Info](https://docs.asciidoctor.org/asciidoctor/latest/cli/)
  * **asciidoctor-pdf**: Converter from AsciiDoc to PDF [Info](https://asciidoctor.org/docs/asciidoctor-pdf/)
  * **asciidoctor-epub3**: Converter from AsciiDoc to EPUB3 and KF8/MOBI [Info](https://docs.asciidoctor.org/epub3-converter/latest/)
  * **asciidoctor-confluence**: Parse asciidoc files them using Asciidoctor and push the result into Confluence [Info](https://github.com/asciidoctor/asciidoctor-confluence)
  * **asciidoctor-fb2**: Converter documents directly to the FB2 e-book format [Info](https://github.com/asciidoctor/asciidoctor-fb2)
  * **asciidoctor-pdf-optimize**: By default, Asciidoctor PDF does not optimize the PDF it generates or compress its streams. [Info](https://github.com/asciidoctor/asciidoctor-pdf#optimizing-the-generated-pdf)
  * **asciidoctor-revealjs**: Converter for Asciidoctor and Asciidoctor.js that transforms an AsciiDoc document into an HTML5 presentation designed to be executed by the reveal.js presentation framework. [Info](https://docs.asciidoctor.org/reveal.js-converter/latest/)
* **ADOC_PATH** : The .adoc file path. Default ```./Readme.md```.
* **ASCIIDOC_ARGS**: The Arguments to be passed to Asciidoctor command, for example ```-a lang=es -a draft=yes```. Each binary can have different arguments, see the information of each binary of **ASCIIDOC_CMD**.
* **ASCIIDOC_IMAGE**: Asciidoctor image to be used. default ```docker.io/asciidoctor/docker-asciidoctor:1.16```.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

In the [tests](../0.1/tests/run.yaml), folder there is an example of the execution of the task, a [PVC](../0.1/tests/pvc.yaml) is used.

## Sample asciidoc code and output

The complete code for the example is in the [repository](https://github.com/jandradap/tekton-asciidoctor-demo).

**Asciidoc code:**
```md
== Title 2

Crystalline XML tags relentlessly bombarded the theater.

.XML tags
[source,xml]
----
<author id="1">
  <personname>
    <firstname>Lazarus</firstname>
    <surname>het Draeke</surname>
  </personname>
</author>
----

Despite the assault, we continued our pursuit to draft a DefOps{empty}footnote:defops[] plan.

.DefOps Plan
====
Click btn:[Download Zip] to download the defensive operation plan bundle.

OMG!
Somebody please save us now!
I want my mum -- and an extra-large double macchiato, please.
====

Unfortunaly, Lazarus and I had both come to the conclusion that we weren't going to get out of 
this without corrupted hardrives if we didn't locate caffeine within the next few hours.

=== Subitle 2

This potion for a sample document contains the following ingredients, which are listed in a 
very random, chaotically nested order.

.Ingredients for Potion that Demystifies Documents
* all the headings
** syntax highlighted source code
*** non-syntax highlighted source code or just a listing block
* quote block
** verse block
*** table with some cell formatting
**** sequential paragraphs
***** admonition blocks, but use them sparingly
*** bullet list with nesting
** numbered list with nesting
** definition list
*** sidebar
```

**Output:**

![Title page](https://raw.githubusercontent.com/jandradap/tekton-asciidoctor-demo/main/images/pag1.png)
![Random page](https://raw.githubusercontent.com/jandradap/tekton-asciidoctor-demo/main/images/pag3.png)
