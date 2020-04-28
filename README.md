# objectscript-json-patch

An implementation of JSON-Path in ObjectScript.

## Why you should use JSON-Patch

JSON-Patch [(RFC6902)](http://tools.ietf.org/html/rfc6902) is a standard format that
allows you to update a JSON document by sending the changes rather than the whole document.
JSON Patch plays well with the HTTP PATCH verb (method) and REST style programming.

## Install

With zpm :
```
USER>zpm
zpm:USER>install objectscript-json-patch
```
## How-To use it 

Use it with this call :

```objectscript
Do ##class(Grongier.JSON.Utils).Patch(tDoc,tPatch)
```
Where :

* tDoc is a %DynamicObject (JSON)
* tPatch is a %DynamicObject of the patch (the JSON Patch).

The result will be *tDoc* patched.

### Example 
```objectscript
Set tDoc = {
            "foo": {
                    "bar": "baz",
                    "waldo": "fred"
                  },
            "qux": {
                    "corge": "grault"
            }
            
Set tPatch = [
              { 
                "op": "move", 
                "from": "/foo/waldo", 
                "path": "/qux/thud" 
              }
             ]

Do ##class(Grongier.JSON.Utils).Patch(tDoc,tPatch)

zw tDoc.%ToJSON()
```
Result
```json
  {
    "foo": {
              "bar": "baz"
           },
    "qux": {
              "corge": "grault",
              "thud": "fred"
          }
   }
 ```
 
 ## Test this module
 
 Natively from git :
 
 ```objectscript
 do ##class(%UnitTest.Manager).DebugRunTestCase("","Test.Grongier.JSON.Utils",,)
 ```
 
 With zpm :
 ```
 USER>zpm
 zpm:USER>module-action objectscript-json-patch test
 ```
