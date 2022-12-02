class JS {
  final String? name;
  const JS([this.name]);
}

class _Anonymous {
  const _Anonymous();
}

const _Anonymous anonymous = _Anonymous();

allowInterop<F extends Function>(F f) {
  throw UnimplementedError();
}

hasProperty(Object o, Object name) => throw UnimplementedError();
getProperty(Object o, Object name) => throw UnimplementedError();
callMethod(Object o, Object to, Object list) => throw UnimplementedError();
promiseToFuture<String>(Object o) => throw UnimplementedError();
