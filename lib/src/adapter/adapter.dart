// Copyright (c) 2021 - 2022 Buijs Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// Wrapper class for transfering response data from Platform to Flutter.
///
/// Wraps an [exception] if calling the platform method has failed to be logged by the consumer.
/// Or wraps an [object] of type T when platform method has returned a response and
/// deserialization was successful.
class AdapterResponse<T> {
  /// Constructor
  AdapterResponse(this._object, this._exception);

  /// Create an AdapterResponse with a response object.
  factory AdapterResponse.success(T? t) => AdapterResponse(t, null);

  /// Create an AdapterResponse with an exception.
  factory AdapterResponse.failure(Exception e) => AdapterResponse(null, e);

  ///The actual object to returned
  T? _object;

  /// Set an object value.
  set object(T object) => _object = object;

  /// Get a non-null object value.
  T get object => _object!;

  ///Exception which occurred when calling a platform method failed.
  Exception? _exception;

  /// Set the exception value.
  set exception(Exception e) => _exception = e;

  /// Get a non-null object value.
  Exception get exception => _exception!;

  /// Returns true if the [_object] is not null.
  bool get isSuccess => _object != null;
}
