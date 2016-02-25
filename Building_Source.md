To build the source code you need: xcode, iOS SDK (3.2 or later) and svn tools.

  * Open new Terminal
  * Create new directory named **mydoubs**
```
mkdir mydoubs
cd mydoubs
```
  * Checkout doubango source code into **mydoubs**. Important: The destination directory MUST be called **doubango**
```
svn checkout http://doubango.googlecode.com/svn/trunk/ doubango
```
  * Create new directory named **iPhone** into **mydoubs**
```
mkdir iPhone
cd iPhone
```
  * Checkout iDoubs source code into **iPhone**
```
svn checkout http://idoubs.googlecode.com/svn/trunk/ idoubs
```
  * change **mydoubs** folder permissions
```
chmod -R 777 mydoubs/*
```

To open & build all projects, open **mydoubs/iPhone/idoubs/iDoubs.xcodeproj**
<br />
<br />
**Note:** You will get many warnings when building the project: "Unused variable ...". This is caused by ragel auto-generated files and you can safely ignore these warnings.