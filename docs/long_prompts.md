Prompt 1:

══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY
╞═══════════════════════════════════════════════════════════
The following ProviderNotFoundException was thrown building Consumer2<AppState,
PositionProvider>(dirty, dependencies: [_InheritedProviderScope<AppState?>]):
Error: Could not find the correct Provider<PositionProvider> above this Consumer2<AppState,
PositionProvider> Widget

This happens because you used a `BuildContext` that does not include the provider
of your choice. There are a few common scenarios:

- You added a new provider in your `main.dart` and performed a hot-reload.
  To fix, perform a hot-restart.

- The provider you are trying to read is in a different route.

  Providers are "scoped". So if you insert of provider inside a route, then
  other routes will not be able to access that provider.

- You used a `BuildContext` that is an ancestor of the provider you are trying to read.

  Make sure that Consumer2<AppState, PositionProvider> is under your
MultiProvider/Provider<PositionProvider>.
  This usually happens when you are creating a provider and trying to read it immediately.

  For example, instead of:

  ```
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // Will throw a ProviderNotFoundError, because `context` is associated
      // to the widget that is the parent of `Provider<Example>`
      child: Text(context.watch<Example>().toString()),
    );
  }
  ```

  consider using `builder` like so:

  ```
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Text(context.watch<Example>().toString());
      }
    );
  }
  ```

If none of these solutions work, consider asking for help on StackOverflow:
https://stackoverflow.com/questions/tagged/flutter

The relevant error-causing widget was:
  Consumer2<AppState, PositionProvider>
  Consumer2:file:///Users/paulripperger/Documents/as-final/UW%20Navigator/lib/screens/map_s
  creen.dart:48:11

When the exception was thrown, this was the stack:
#0      Provider._inheritedElementOf (package:provider/src/provider.dart:377:7)
#1      Provider.of (package:provider/src/provider.dart:327:30)
#2      Consumer2.buildWithChild (package:provider/src/consumer.dart:209:16)
#3      SingleChildStatelessWidget.build (package:nested/nested.dart:259:41)
#4      StatelessElement.build (package:flutter/src/widgets/framework.dart:5889:49)
#5      SingleChildStatelessElement.build (package:nested/nested.dart:279:18)
#6      ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5817:15)
#7      Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#8      ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:5799:5)
#9      ComponentElement.mount (package:flutter/src/widgets/framework.dart:5793:5)
#10     SingleChildWidgetElementMixin.mount (package:nested/nested.dart:222:11)
#11     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)
#12     MultiChildRenderObjectElement.inflateWidget
(package:flutter/src/widgets/framework.dart:7264:36)
#13     MultiChildRenderObjectElement.mount
(package:flutter/src/widgets/framework.dart:7279:32)
...     Normal element mounting (25 frames)
#38     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)
#39     MultiChildRenderObjectElement.inflateWidget
(package:flutter/src/widgets/framework.dart:7264:36)
#40     MultiChildRenderObjectElement.mount
(package:flutter/src/widgets/framework.dart:7279:32)
...     Normal element mounting (151 frames)
#191    Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)
#192    Element.updateChild (package:flutter/src/widgets/framework.dart:4059:18)
#193    SliverMultiBoxAdaptorElement.updateChild
(package:flutter/src/widgets/sliver.dart:1086:37)
#194    SliverMultiBoxAdaptorElement.createChild.<anonymous closure>
(package:flutter/src/widgets/sliver.dart:1071:20)
#195    BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3101:19)
#196    SliverMultiBoxAdaptorElement.createChild
(package:flutter/src/widgets/sliver.dart:1061:12)
#197    RenderSliverMultiBoxAdaptor._createOrObtainChild.<anonymous closure>
(package:flutter/src/rendering/sliver_multi_box_adaptor.dart:368:23)
#198    RenderObject.invokeLayoutCallback.<anonymous closure>
(package:flutter/src/rendering/object.dart:3026:17)
#199    PipelineOwner._enableMutationsToDirtySubtrees
(package:flutter/src/rendering/object.dart:1223:15)
#200    RenderObject.invokeLayoutCallback
(package:flutter/src/rendering/object.dart:3025:14)
#201    RenderSliverMultiBoxAdaptor._createOrObtainChild
(package:flutter/src/rendering/sliver_multi_box_adaptor.dart:357:5)
#202    RenderSliverMultiBoxAdaptor.addInitialChild
(package:flutter/src/rendering/sliver_multi_box_adaptor.dart:455:5)
#203    RenderSliverFixedExtentBoxAdaptor.performLayout
(package:flutter/src/rendering/sliver_fixed_extent_list.dart:341:12)
#204    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#205    RenderSliverEdgeInsetsPadding.performLayout
(package:flutter/src/rendering/sliver_padding.dart:133:12)
#206    _RenderSliverFractionalPadding.performLayout
(package:flutter/src/widgets/sliver_fill.dart:174:11)
#207    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#208    RenderViewportBase.layoutChildSequence
(package:flutter/src/rendering/viewport.dart:821:13)
#209    RenderViewport._attemptLayout (package:flutter/src/rendering/viewport.dart:1831:12)
#210    RenderViewport.performLayout (package:flutter/src/rendering/viewport.dart:1724:20)
#211    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#212    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#213    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#214    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#215    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#216    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#217    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#218    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#219    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#220    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#221    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#222    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#223    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#224    MultiChildLayoutDelegate.layoutChild
(package:flutter/src/rendering/custom_layout.dart:180:12)
#225    _ScaffoldLayout.performLayout (package:flutter/src/material/scaffold.dart:1113:7)
#226    MultiChildLayoutDelegate._callPerformLayout
(package:flutter/src/rendering/custom_layout.dart:246:7)
#227    RenderCustomMultiChildLayoutBox.performLayout
(package:flutter/src/rendering/custom_layout.dart:417:14)
#228    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#229    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#230    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#231    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#232    _RenderCustomClip.performLayout
(package:flutter/src/rendering/proxy_box.dart:1549:11)
#233    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#234    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#235    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#236    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#237    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#238    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#239    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#240    ChildLayoutHelper.layoutChild
(package:flutter/src/rendering/layout_helper.dart:62:11)
#241    RenderStack._computeSize (package:flutter/src/rendering/stack.dart:647:43)
#242    RenderStack.performLayout (package:flutter/src/rendering/stack.dart:682:12)
#243    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#244    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#245    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#246    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#247    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#248    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#249    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#250    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#251    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#252    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#253    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#254    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#255    RenderOffstage.performLayout (package:flutter/src/rendering/proxy_box.dart:3923:13)
#256    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#257    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#258    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#259    _RenderTheaterMixin.layoutChild (package:flutter/src/widgets/overlay.dart:1124:13)
#260    _RenderTheater.performLayout (package:flutter/src/widgets/overlay.dart:1481:9)
#261    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#262    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#263    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#264    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#265    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#266    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#267    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#268    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#269    RenderCustomPaint.performLayout
(package:flutter/src/rendering/custom_paint.dart:574:11)
#270    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#271    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#272    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#273    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#274    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#275    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#276    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#277    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#278    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#279    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#280    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#281    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#282    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#283    RenderProxyBoxMixin.performLayout
(package:flutter/src/rendering/proxy_box.dart:118:18)
#284    RenderObject.layout (package:flutter/src/rendering/object.dart:2907:7)
#285    RenderView.performLayout (package:flutter/src/rendering/view.dart:292:12)
#286    RenderObject._layoutWithoutResize
(package:flutter/src/rendering/object.dart:2755:7)
#287    PipelineOwner.flushLayout (package:flutter/src/rendering/object.dart:1174:18)
#288    PipelineOwner.flushLayout (package:flutter/src/rendering/object.dart:1187:15)
#289    RendererBinding.drawFrame (package:flutter/src/rendering/binding.dart:643:23)
#290    WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1573:13)
#291    RendererBinding._handlePersistentFrameCallback
(package:flutter/src/rendering/binding.dart:509:5)
#292    SchedulerBinding._invokeFrameCallback
(package:flutter/src/scheduler/binding.dart:1430:15)
#293    SchedulerBinding.handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1345:9)
#294    SchedulerBinding.scheduleWarmUpFrame.<anonymous closure>
(package:flutter/src/scheduler/binding.dart:1055:9)
#295    PlatformDispatcher.scheduleWarmUpFrame.<anonymous closure>
(dart:ui/platform_dispatcher.dart:909:16)
#299    _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)
(elided 3 frames from class _Timer and dart:async-patch)

═══════════════════════════════════════════════════════════════════════════════════════════
═════════


Prompt 2:


A Dart VM Service on iPhone 17 is available at: http://127.0.0.1:53048/Qyz_h-JZ_i4=/
The Flutter DevTools debugger and profiler on iPhone 17 is available at:
http://127.0.0.1:53048/Qyz_h-JZ_i4=/devtools/?uri=ws://127.0.0.1:53048/Qyz_h-JZ_i4=/ws
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Permission definitions not found in the app's Info.plist. Please make sure to add either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription to the app's Info.plist file on iOS. If running on macOS please add NSLocationUsageDescription to the app's Info.plist file.
#0      GeolocatorApple.requestPermission (package:geolocator_apple/src/geolocator_apple.dart:63:7)
<asynchronous suspension>
#1      PositionProvider._determinePosition (package:uw_navigator/providers/position_provider.dart:53:20)
<asynchronous suspension>
#2      PositionProvider._updatePoisition (package:uw_navigator/providers/position_provider.dart:26:31)
<asynchronous suspension>
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Permission definitions not found in the app's Info.plist. Please make sure to add either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription to the app's Info.plist file on iOS. If running on macOS please add NSLocationUsageDescription to the app's Info.plist file.
#0      GeolocatorApple.requestPermission (package:geolocator_apple/src/geolocator_apple.dart:63:7)
<asynchronous suspension>
#1      PositionProvider._determinePosition (package:uw_navigator/providers/position_provider.dart:53:20)
<asynchronous suspension>
#2      PositionProvider._updatePoisition (package:uw_navigator/providers/position_provider.dart:26:31)
<asynchronous suspension>
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Permission definitions not found in the app's Info.plist. Please make sure to add either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription to the app's Info.plist file on iOS. If running on macOS please add NSLocationUsageDescription to the app's Info.plist file.
#0      GeolocatorApple.requestPermission (package:geolocator_apple/src/geolocator_apple.dart:63:7)
<asynchronous suspension>
#1      PositionProvider._determinePosition (package:uw_navigator/providers/position_provider.dart:53:20)
<asynchronous suspension>
#2      PositionProvider._updatePoisition (package:uw_navigator/providers/position_provider.dart:26:31)
<asynchronous suspension>
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Permission definitions not found in the app's Info.plist. Please make sure to add either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription to the app's Info.plist file on iOS. If running on macOS please add NSLocationUsageDescription to the app's Info.plist file.
#0      GeolocatorApple.requestPermission (package:geolocator_apple/src/geolocator_apple.dart:63:7)
<asynchronous suspension>
#1      PositionProvider._determinePosition (package:uw_navigator/providers/position_provider.dart:53:20)
<asynchronous suspension>
#2      PositionProvider._updatePoisition (package:uw_navigator/providers/position_provider.dart:26:31)
<asynchronous suspension>
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Permission definitions not found in the app's Info.plist. Please make sure to add either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription to the app's Info.plist file on iOS. If running on macOS please add NSLocationUsageDescription to the app's Info.plist file.
#0      GeolocatorApple.requestPermission (package:geolocator_apple/src/geolocator_apple.dart:63:7)
<asynchronous suspension>
#1      PositionProvider._determinePosition (package:uw_navigator/providers/position_provider.dart:53:20)
<asynchronous suspension>
#2      PositionProvider._updatePoisition (package:uw_navigator/providers/position_provider.dart:26:31)
<asynchronous suspension>
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Permission definitions not found in the app's Info.plist. Please make sure to add either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription to the app's Info.plist file on iOS. If running on macOS please add NSLocationUsageDescription to the app's Info.plist file.
#0      GeolocatorApple.requestPermission (package:geolocator_apple/src/geolocator_apple.dart:63:7)
<asynchronous suspension>
#1      PositionProvider._determinePosition (package:uw_navigator/providers/position_provider.dart:53:20)
<asynchronous suspension>
#2      PositionProvider._updatePoisition (package:uw_navigator/providers/position_provider.dart:26:31)
<asynchronous suspension>
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Permission definitions not found in the app's Info.plist. Please make sure to add either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription to the app's Info.plist file on iOS. If running on macOS please add NSLocationUsageDescription to the app's Info.plist file.
#0      GeolocatorApple.requestPermission (package:geolocator_apple/src/geolocator_apple.dart:63:7)
<asynchronous suspension>
#1      PositionProvider._determinePosition (package:uw_navigator/providers/position_provider.dart:53:20)
<asynchronous suspension>
#2      PositionProvider._updatePoisition (package:uw_navigator/providers/position_provider.dart:26:31)
<asynchronous suspension>