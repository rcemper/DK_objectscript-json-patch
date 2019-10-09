Class Test.REST.JSON.Utils Extends %UnitTest.TestCase
{

Method AddMissingObj() As %Status
{
        set tTest = {
            "comment": "4.1. add with missing object",
            "doc": { "q": { "bar": 2 } },
            "patch": [ {"op": "add", "path": "/a/b", "value": 1} ],
            "error":
                "path /a does not exist -- missing objects are not created recursively"
        }

        set tDoc = tTest.doc
        set tPatch = tTest.patch
        do $$$AssertStatusNotOK(##class(REST.JSON.Utils).Patch(tDoc,tPatch,.Update))

        Quit $$$OK
}

ClassMethod AddObjMember() As %Status
{
        set tTest =     
  {
    "comment": "A.6.  Moving a Value",
    "doc": {
  "foo": {
    "bar": "baz",
    "waldo": "fred"
  },
  "qux": {
    "corge": "grault"
  }
    },
    "patch": [
  { "op": "move", "from": "/foo/waldo", "path": "/qux/thud" }
    ],
    "expected": {
  "foo": {
    "bar": "baz"
  },
  "qux": {
    "corge": "grault",
    "thud": "fred"
  }
    }
  }

        set tDoc = tTest.doc
        zw tDoc
        set tPatch = tTest.patch
        set tExpected = tTest.expected
        do ##class(REST.JSON.Utils).Patch(tDoc,tPatch,.Update)
        zw tDoc
        zw tExpected

        Quit $$$OK
}

}
