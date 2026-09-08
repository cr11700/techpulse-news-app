# pg_GraphQL introspection代码

## 生成：
查询这一graphql
```graphql
query IntrospectionQuery {
  __schema {
    queryType { name }
    mutationType { name }
    subscriptionType { name }
    types {
      ...FullType
    }
    directives {
      name
      description
      locations
      args {
        ...InputValue
      }
    }
  }
}

fragment FullType on __Type {
  kind
  name
  description
  fields(includeDeprecated: true) {
    name
    description
    args {
      ...InputValue
    }
    type {
      ...TypeRef
    }
    isDeprecated
    deprecationReason
  }
  inputFields {
    ...InputValue
  }
  interfaces {
    ...TypeRef
  }
  enumValues(includeDeprecated: true) {
    name
    description
    isDeprecated
    deprecationReason
  }
  possibleTypes {
    ...TypeRef
  }
}

fragment InputValue on __InputValue {
  name
  description
  type { ...TypeRef }
  defaultValue
}

fragment TypeRef on __Type {
  kind
  name
  ofType {
    kind
    name
    ofType {
      kind
      name
      ofType {
        kind
        name
      }
    }
  }
}
```

```bash
graphql-inspector introspect schema.json --write schema.graphql
dart run build_runner build --delete-conflicting-outputs
```

## 根据标签查询文章
创建函数
```sql
CREATE OR REPLACE FUNCTION get_articles_by_tag(tagid int4)
RETURNS SETOF article
immutable   -- 注意这个不能省略，默认是volatile，会变成mutation
LANGUAGE sql
AS $$
  SELECT a.*
  FROM article a
  JOIN article_tag at
    ON at.article_id = a.article_id
  WHERE at.tag_id = tagid;
$$;
```

使用graphql查询
```graphql
query HomePageArticleByTag($tag: Int, $after: Cursor) {
    get_articles_by_tag(tagid: $tag, after: $after, orderBy: { pubtime: DescNullsLast }) {
        edges {
            node {
                nodeId
                title_cn
                url
                pubtime
              	header_img
                thumb_img
                author {
                    nodeId
                    name
                    avatar
                }
              	publisher {
                  name
                }
            }
        }
        pageInfo {
            endCursor
            hasNextPage
        }
    }
}
```

## 根据新闻来源（出版社）查询文章
使用graphql查询
```graphql
query HomePageArticleByPublisher($publisherId: Int, $after: Cursor) {
    articleCollection(filter: { publisher_id: { eq: $publisherId } }, after: $after, orderBy: { pubtime: DescNullsLast }) {
        edges {
            node {
                nodeId
                title_cn
                url
                pubtime
              	header_img
                thumb_img
                author {
                    nodeId
                    name
                    avatar
                }
              	publisher {
                  name
                }
            }
        }
        pageInfo {
            endCursor
            hasNextPage
        }
    }
}
```
