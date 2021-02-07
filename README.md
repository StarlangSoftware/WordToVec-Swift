For Developers
============
You can also see [Java](https://github.com/olcaytaner/WordToVec), [Python](https://github.com/olcaytaner/WordToVec-Py), [Cython](https://github.com/olcaytaner/WordToVec-Cy), [C#](https://github.com/starlangsoftware/WordToVec-CS), or [C++](https://github.com/olcaytaner/WordToVec-CPP) repository.

## Requirements

* Xcode Editor
* [Git](#git)

### Git

Install the [latest version of Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

## Download Code

In order to work on code, create a fork from GitHub page. 
Use Git for cloning the code to your local or below line for Ubuntu:

	git clone <your-fork-git-link>

A directory called WordToVec-Swift will be created. Or you can use below link for exploring the code:

	git clone https://github.com/starlangsoftware/WordToVec-Swift.git

## Open project with XCode

To import projects from Git with version control:

* XCode IDE, select Clone an Existing Project.

* In the Import window, paste github URL.

* Click Clone.

Result: The imported project is listed in the Project Explorer view and files are loaded.


## Compile

**From IDE**

After being done with the downloading and opening project, select **Build** option from **Product** menu. After compilation process, user can run WordToVec-Swift.

Detailed Description
============

To initialize artificial neural network:

	init(corpus: Corpus, parameter: WordToVecParameter)

To train neural network:

	func train() -> VectorizedDictionary
