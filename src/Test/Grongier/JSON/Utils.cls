/// Run all test
/// do ##class(%UnitTest.Manager).DebugRunTestCase("","Test.Grongier.JSON.Utils",,)
Class Test.Grongier.JSON.Utils Extends %UnitTest.TestCase
{

Method TestAddMissingObj()
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
  set tExpexted = tTest.expected
  do $$$AssertStatusNotOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
}

Method TestAddObjMember()
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
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestAddArrayElement()
{
        set tTest =     
  {
    "comment": "A.2.  Adding an Array Element",
    "doc": {
  "foo": [ "bar", "baz" ]
  },
    "patch": [
  { "op": "add", "path": "/foo/1", "value": "qux" }
  ],
    "expected": {
  "foo": [ "bar", "qux", "baz" ]
  }
  }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestRemoveObjectMember()
{
        set tTest =     
 {
    "comment": "A.3.  Removing an Object Member",
    "doc": {
  "baz": "qux",
  "foo": "bar"
 },
    "patch": [
  { "op": "remove", "path": "/baz" }
 ],
    "expected": {
  "foo": "bar"
 }
  }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestRemoveArreyElement()
{
        set tTest =     
   {
    "comment": "A.4.  Removing an Array Element",
    "doc": {
  "foo": [ "bar", "qux", "baz" ]
 },
    "patch": [
  { "op": "remove", "path": "/foo/1" }
 ],
    "expected": {
  "foo": [ "bar", "baz" ]
 }
  }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestReplaceValue()
{
        set tTest =     
    {
      "comment": "A.5.  Replacing a Value",
      "doc": {
    "baz": "qux",
    "foo": "bar"
  },
      "patch": [
    { "op": "replace", "path": "/baz", "value": "boo" }
  ],
      "expected": {
    "baz": "boo",
    "foo": "bar"
  }
    }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestMoveValue()
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
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestValueError()
{
        set tTest =     
    {
      "comment": "A.9.  Testing a Value: Error",
      "doc": {
    "baz": "qux"
  },
      "patch": [
    { "op": "test", "path": "/baz", "value": "bar" }
  ],
      "error": "string not equivalent"
    }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusNotOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
}

Method TestAddNestedMemberObj()
{
        set tTest =     
   {
    "comment": "A.10.  Adding a nested Member Object",
      "doc": {
    "foo": "bar"
  },
      "patch": [
    { "op": "add", "path": "/child", "value": { "grandchild": { } } }
  ],
      "expected": {
    "foo": "bar",
    "child": {
      "grandchild": {
      }
    }
  }
    }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestIgnoringUnrecognized()
{
        set tTest =     

  {
    "comment": "A.11.  Ignoring Unrecognized Elements",
    "doc": {
  "foo":"bar"
  },
      "patch": [
    { "op": "add", "path": "/baz", "value": "qux", "xyz": 123 }
  ],
      "expected": {
    "foo":"bar",
    "baz":"qux"
  }
    }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestUnrecognizedTarget()
{
        set tTest =     

  {
      "comment": "A.12.  Adding to a Non-existent Target",
      "doc": {
    "foo": "bar"
  },
      "patch": [
    { "op": "add", "path": "/baz/bat", "value": "qux" }
  ],
      "error": "add to a non-existent target"
    }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusNotOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
}

Method TestInvalidPatch()
{
        set tTest =     

  {
      "comment": "A.13 Invalid JSON Patch Document",
      "doc": {
      "foo": "bar"
      },
      "patch": [
    { "op": "add", "path": "/baz", "value": "qux", "op": "remove" }
  ],
      "error": "operation has two 'op' members",
      "disabled": true
    }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusNotOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
}

Method TestEscapeOrder()
{
        set tTest =     
  {
    "comment": "A.14. ~ Escape Ordering",
    "doc": {
       "/": 9,
       "~1": 10
    },
    "patch": [{"op": "test", "path": "/~1", "value": 10}],
    "expected": {
       "/": 9,
       "~1": 10
    }
  }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestAddArray()
{
        set tTest =     
  {
    "comment": "A.16. Adding an Array Value",
    "doc": {
       "foo": ["bar"]
    },
    "patch": [{ "op": "add", "path": "/foo/-", "value": ["abc", "def"] }],
    "expected": {
      "foo": ["bar", ["abc", "def"]]
    }
  }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
  do $$$AssertEquals(tDoc.%ToJSON(),tExpexted.%ToJSON())
}

Method TestCompStringNum()
{
        set tTest =     
  {
    "comment": "A.15. Comparing Strings and Numbers",
    "doc": {
       "/": 9,
       "~1": 10
    },
    "patch": [{"op": "test", "path": "/~01", "value": "10"}],
    "error": "number is not equal to string"
  }

  set tDoc = tTest.doc
  set tPatch = tTest.patch
  set tExpexted = tTest.expected
  do $$$AssertStatusNotOK(##class(Grongier.JSON.Utils).Patch(tDoc,tPatch,.Update))
}

}
