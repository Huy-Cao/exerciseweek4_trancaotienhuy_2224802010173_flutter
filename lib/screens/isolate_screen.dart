import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
Map<String,dynamic> _computeFactorial(int n)
{
  double logSum=0.0;
  for(int i=2;i<=n;i++)
  {
    logSum+=log(i)/ln10;
  }
  final int digitCount=logSum.floor()+1;
  final double fractional=logSum-logSum.floor();
  final double mantissa=pow(10,fractional).toDouble();
  final String preview='${mantissa.toStringAsFixed(8).replaceAll('.','')}'
      '... (x10^${digitCount-1})';
  return {
    'digitCount':digitCount,
    'preview':preview,
  };
}
void _randomNumberWorker(SendPort mainSendPort)
{
  final receivePort=ReceivePort();
  mainSendPort.send(receivePort.sendPort);
  final random=Random();
  bool running=true;
  receivePort.listen((message)
  {
    if(message=='stop')
    {
      running=false;
      receivePort.close();
      Isolate.exit();
    }
  });
  Future.doWhile(() async
  {
    if(!running) return false;
    final num=random.nextInt(20)+1;
    mainSendPort.send(num);
    await Future.delayed(const Duration(seconds:1));
    return running;
  });
}
class IsolateScreen extends StatefulWidget
{
  const IsolateScreen({super.key});
  @override
  State<IsolateScreen> createState()=>_IsolateScreenState();
}
class _IsolateScreenState extends State<IsolateScreen>
    with SingleTickerProviderStateMixin
{
  late TabController _tabController;
  @override
  void initState()
  {
    super.initState();
    _tabController=TabController(length:2,vsync:this);
  }
  @override
  void dispose()
  {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return Scaffold(
      appBar:AppBar(
        title:const Text('Exercise 5 — Isolates'),
        backgroundColor:colorScheme.surfaceContainer,
        bottom:TabBar(
          controller:_tabController,
          tabs:const
          [
            Tab(icon:Icon(Icons.calculate),text:'Challenge 1'),
            Tab(icon:Icon(Icons.swap_horiz),text:'Challenge 2'),
          ],
        ),
      ),
      body:TabBarView(
        controller:_tabController,
        children:const
        [
          _Challenge1Tab(),
          _Challenge2Tab(),
        ],
      ),
    );
  }
}
class _Challenge1Tab extends StatefulWidget
{
  const _Challenge1Tab();
  @override
  State<_Challenge1Tab>createState()=>_Challenge1TabState();
}
class _Challenge1TabState extends State<_Challenge1Tab>
{
  static const int _targetN=30000;
  bool _isComputing=false;
  int? _digitCount;
  String? _preview;
  String? _errorMsg;
  Duration? _elapsed;
  Future<void> _startComputation() async
  {
    setState(()
    {
      _isComputing=true;
      _digitCount=null;
      _preview=null;
      _errorMsg=null;
      _elapsed=null;
    });
    final stopwatch=Stopwatch()..start();
    try
    {
      final result=await compute(_computeFactorial,_targetN);
      stopwatch.stop();
      if(mounted)
      {
        setState(()
        {
          _isComputing=false;
          _digitCount=result['digitCount']as int;
          _preview=result['preview']as String;
          _elapsed=stopwatch.elapsed;
        });
      }
    }
    catch(e)
    {
      stopwatch.stop();
      if(mounted)
      {
        setState(()
        {
          _isComputing=false;
          _errorMsg=e.toString();
        });
      }
    }
  }
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding:const EdgeInsets.all(20),
      child:Column(
        crossAxisAlignment:CrossAxisAlignment.stretch,
        children:
        [
          Card(
            elevation:0,
            color:colorScheme.secondaryContainer.withOpacity(0.5),
            shape:RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(16),
                side:BorderSide(color:colorScheme.secondary.withOpacity(0.2))),
            child:Padding(
              padding:const EdgeInsets.all(16),
              child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children:
                [
                  Row(children:
                  [
                    Icon(Icons.info_outline,color:colorScheme.secondary,size:18),
                    const SizedBox(width:8),
                    Text('About this challenge',
                        style:TextStyle(
                            fontWeight:FontWeight.bold,
                            color:colorScheme.secondary)),
                  ]),
                  const SizedBox(height:8),
                  const Text(
                    'Calculates 30,000! (factorial) using a background isolate '
                        'via Flutter\'s compute() function, keeping the UI thread free.',
                    style:TextStyle(fontSize:13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height:24),
          Container(
            padding:const EdgeInsets.all(20),
            decoration:BoxDecoration(
              color:colorScheme.surfaceContainer,
              borderRadius:BorderRadius.circular(16),
            ),
            child:Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children:
              [
                Text('Computing:  ',
                    style:TextStyle(color:colorScheme.onSurfaceVariant)),
                Text('$_targetN !',
                    style:TextStyle(
                        fontSize:28,
                        fontWeight:FontWeight.bold,
                        color:colorScheme.primary)),
              ],
            ),
          ),
          const SizedBox(height:20),
          AnimatedSwitcher(
            duration:const Duration(milliseconds:350),
            child:_isComputing
                ?_ComputingCard(key:const ValueKey('computing'))
                :_digitCount!=null
                ?_ResultCard(
              key:const ValueKey('result'),
              digitCount:_digitCount!,
              preview:_preview!,
              elapsed:_elapsed!,
            )
                :_errorMsg!=null?_ErrorCard(
              key:const ValueKey('error'),
              message:_errorMsg!,
            )
                :const _IdleCard(key:ValueKey('idle')),
          ),
          const SizedBox(height:24),
          FilledButton.icon(
            onPressed:_isComputing?null:_startComputation,
            icon:_isComputing
                ?const SizedBox(
                width:18,
                height:18,
                child:CircularProgressIndicator(
                    strokeWidth:2,color:Colors.white))
                :const Icon(Icons.play_arrow_rounded),
            label:Text(_isComputing?'Computing in isolate...':'Start Computation'),
            style: FilledButton.styleFrom(
                padding:const EdgeInsets.symmetric(vertical:14)),
          ),
        ],
      ),
    );
  }
}
class _IdleCard extends StatelessWidget
{
  const _IdleCard({super.key});
  @override
  Widget build(BuildContext context)
  {
    return Container(
      padding:const EdgeInsets.all(24),
      decoration:BoxDecoration(
        color:Theme.of(context).colorScheme.surfaceContainer,
        borderRadius:BorderRadius.circular(16),
      ),
      child:const Center(
        child:Text('Press the button to start computing 30,000!',
            style:TextStyle(fontSize:14)),
      ),
    );
  }
}
class _ComputingCard extends StatelessWidget
{
  const _ComputingCard({super.key});
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return Container(
      padding:const EdgeInsets.all(24),
      decoration:BoxDecoration(
        color:colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius:BorderRadius.circular(16),
      ),
      child:Column(
        children:
        [
          const CircularProgressIndicator(),
          const SizedBox(height:16),
          Text('Running in background isolate...',
              style:TextStyle(
                  fontWeight:FontWeight.w600,color:colorScheme.primary)),
          const SizedBox(height:8),
          Text('UI remains responsive while computing.',
              style:TextStyle(
                  fontSize:12,color:colorScheme.onSurfaceVariant)),
          const SizedBox(height:16),
          const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
class _ResultCard extends StatelessWidget
{
  final int digitCount;
  final String preview;
  final Duration elapsed;
  const _ResultCard({
    super.key,
    required this.digitCount,
    required this.preview,
    required this.elapsed,
  });
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return Container(
      padding:const EdgeInsets.all(20),
      decoration:BoxDecoration(
        color:Colors.green.shade50,
        borderRadius:BorderRadius.circular(16),
        border:Border.all(color:Colors.green.shade200),
      ),
      child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children:
        [
          Row(children:
          [
            Icon(Icons.check_circle,color:Colors.green.shade600),
            const SizedBox(width:8),
            Text('Computation Complete!',
                style:TextStyle(
                    fontWeight:FontWeight.bold,
                    color:Colors.green.shade700,
                    fontSize:15)),
          ]),
          const SizedBox(height:16),
          _InfoRow(label:'Number of digits',value:'$digitCount digits'),
          const Divider(height:20),
          _InfoRow(label:'Leading digits',value:preview),
          const Divider(height:20),
          _InfoRow(
              label:'Time elapsed',
              value:'${elapsed.inSeconds}.${(elapsed.inMilliseconds%1000).toString().padLeft(3,'0')} s'),
          const Divider(height:20),
          Row(children:
          [
            Icon(Icons.memory,size:14,color:colorScheme.onSurfaceVariant),
            const SizedBox(width:6),
            Text('Computed in a background isolate via compute()',
                style:TextStyle(
                    fontSize:11,color:colorScheme.onSurfaceVariant)),
          ]),
        ],
      ),
    );
  }
}
class _ErrorCard extends StatelessWidget
{
  final String message;
  const _ErrorCard({super.key,required this.message});
  @override
  Widget build(BuildContext context)
  {
    return Container(
      padding:const EdgeInsets.all(20),
      decoration:BoxDecoration(
        color:Colors.red.shade50,
        borderRadius:BorderRadius.circular(16),
        border:Border.all(color:Colors.red.shade200),
      ),
      child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children:
        [
          Row(children:
          [
            Icon(Icons.error_outline,color:Colors.red.shade600),
            const SizedBox(width:8),
            const Text('Error occurred',
                style:
                TextStyle(fontWeight:FontWeight.bold,color:Colors.red)),
          ]),
          const SizedBox(height:8),
          Text(message,style:const TextStyle(fontSize:12)),
        ],
      ),
    );
  }
}
class _InfoRow extends StatelessWidget
{
  final String label;
  final String value;
  const _InfoRow({required this.label,required this.value});
  @override
  Widget build(BuildContext context)
  {
    return Row(
      crossAxisAlignment:CrossAxisAlignment.start,
      children:
      [
        Expanded(
          flex:2,
          child:Text(label,
              style:TextStyle(
                  fontSize:12,
                  color:Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          flex:3,
          child:Text(value,
              style:const TextStyle(
                  fontSize:13,fontWeight:FontWeight.w600),
              overflow:TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
class _Challenge2Tab extends StatefulWidget
{
  const _Challenge2Tab();
  @override
  State<_Challenge2Tab> createState()=>_Challenge2TabState();
}
class _Challenge2TabState extends State<_Challenge2Tab>
{
  ReceivePort? _receivePort;
  SendPort? _workerSendPort;
  Isolate? _isolate;
  bool _isRunning=false;
  bool _stopped=false;
  int _sum=0;
  final List<_NumberEvent> _events=[];
  static const int _stopThreshold=100;
  Future<void> _startWorker() async
  {
    setState(()
    {
      _isRunning=true;
      _stopped=false;
      _sum=0;
      _events.clear();
    });
    _receivePort=ReceivePort();
    _isolate=await Isolate.spawn(
      _randomNumberWorker,
      _receivePort!.sendPort,
    );
    _receivePort!.listen((message)
    {
      if(message is SendPort)
      {
        _workerSendPort=message;
      }
      else if(message is int && mounted)
      {
        setState(()
        {
          _sum+=message;
          _events.add(_NumberEvent(value:message,runningSum:_sum));
        });
        if(_sum>_stopThreshold&&!_stopped)
        {
          _stopWorker();
        }
      }
    });
  }
  void _stopWorker()
  {
    if(_stopped) return;
    _workerSendPort?.send('stop');
    setState(()
    {
      _stopped=true;
      _isRunning=false;
    });
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort=null;
    _workerSendPort=null;
    _isolate=null;
  }
  void _reset()
  {
    _stopWorker();
    setState(()
    {
      _sum=0;
      _events.clear();
      _stopped=false;
    });
  }
  @override
  void dispose()
  {
    _stopWorker();
    super.dispose();
  }
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return Column(
      children:
      [
        Padding(
          padding:const EdgeInsets.fromLTRB(16,16,16,0),
          child:Column(
            children:
            [
              Card(
                elevation:0,
                color:colorScheme.tertiaryContainer.withOpacity(0.5),
                shape:RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(14),
                    side:BorderSide(
                        color:colorScheme.tertiary.withOpacity(0.2))),
                child:Padding(
                  padding:const EdgeInsets.all(14),
                  child:Row(
                    children:
                    [
                      Icon(Icons.info_outline,
                          color:colorScheme.tertiary,size:16),
                      const SizedBox(width:8),
                      Expanded(
                        child:Text(
                          'Spawns a background isolate that sends random numbers '
                              'each second. Main isolate sums them and sends "stop" '
                              'when sum > $_stopThreshold.',
                          style:const TextStyle(fontSize:12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height:16),
              AnimatedContainer(
                duration:const Duration(milliseconds:300),
                padding:const EdgeInsets.symmetric(vertical:16,horizontal:20),
                decoration:BoxDecoration(
                  color:_stopped?Colors.orange.shade50:_isRunning
                      ?colorScheme.primaryContainer.withOpacity(0.5)
                      :colorScheme.surfaceContainer,
                  borderRadius:BorderRadius.circular(16),
                  border:Border.all(
                    color:_stopped?Colors.orange.shade300:_isRunning
                        ?colorScheme.primary.withOpacity(0.4)
                        :colorScheme.outlineVariant,
                  ),
                ),
                child:Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  children:
                  [
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children:[
                        Text('Running Sum',
                            style:TextStyle(
                                fontSize:11,
                                color:colorScheme.onSurfaceVariant)),
                        Text(
                          '$_sum',
                          style:TextStyle(
                            fontSize:36,
                            fontWeight:FontWeight.bold,
                            color:_stopped
                                ?Colors.orange.shade700
                                :colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.end,
                      children:
                      [
                        _StatusBadge(
                          label:_stopped
                              ?'Stopped ✓'
                              :_isRunning
                              ?'Running'
                              :'Idle',
                          color:_stopped
                              ?Colors.orange
                              :_isRunning
                              ?colorScheme.primary
                              :colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height:8),
                        Text('Threshold:$_stopThreshold',
                            style:TextStyle(
                                fontSize:11,
                                color:colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height:14),
              Row(
                children:
                [
                  Expanded(
                    child:FilledButton.icon(
                      onPressed:_isRunning?null:_startWorker,
                      icon:const Icon(Icons.play_arrow_rounded),
                      label:const Text('Start Isolate'),
                      style:FilledButton.styleFrom(
                          padding:const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width:10),
                  Expanded(
                    child:OutlinedButton.icon(
                      onPressed:_isRunning?_stopWorker:null,
                      icon:const Icon(Icons.stop_rounded),
                      label:const Text('Stop'),
                      style:OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical:12)),
                    ),
                  ),
                  const SizedBox(width:10),
                  IconButton.outlined(
                    onPressed:_reset,
                    icon:const Icon(Icons.refresh_rounded),
                    tooltip:'Reset',
                    style:IconButton.styleFrom(
                        padding:const EdgeInsets.all(12)),
                  ),
                ],
              ),
              const SizedBox(height:12),
              if(_stopped)
                Container(
                  padding:const EdgeInsets.all(12),
                  decoration:BoxDecoration(
                    color:Colors.orange.shade50,
                    borderRadius:BorderRadius.circular(12),
                    border:Border.all(color:Colors.orange.shade200),
                  ),
                  child:Row(
                    children:
                    [
                      Icon(Icons.check_circle,
                          color:Colors.orange.shade700,size:18),
                      const SizedBox(width:8),
                      Expanded(
                        child:Text(
                          'Sum exceeded $_stopThreshold! Stop command sent → '
                              'worker isolate exited via Isolate.exit().',
                          style:TextStyle(
                              fontSize:12,color:Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height:12),
        Divider(height:1,color:Theme.of(context).colorScheme.outlineVariant),
        Expanded(
          child:_events.isEmpty?Center(
            child:Text('No events yet.',
                style:TextStyle(
                    color:colorScheme.onSurfaceVariant)),
          )
              :ListView.builder(
            padding:const EdgeInsets.symmetric(
                horizontal:16,vertical:8),
            itemCount:_events.length,
            itemBuilder:(context,i)
            {
              final event=_events[_events.length-1-i];
              final isStop=event.runningSum>_stopThreshold;
              return _EventTile(event:event,triggered:isStop&&i==0);
            },
          ),
        ),
      ],
    );
  }
}
class _NumberEvent
{
  final int value;
  final int runningSum;
  _NumberEvent({required this.value,required this.runningSum});
}
class _EventTile extends StatelessWidget
{
  final _NumberEvent event;
  final bool triggered;
  const _EventTile({required this.event,required this.triggered});
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return Container(
      margin:const EdgeInsets.symmetric(vertical:3),
      padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),
      decoration:BoxDecoration(
        color:triggered
            ?Colors.orange.shade50
            :colorScheme.surfaceContainer,
        borderRadius:BorderRadius.circular(10),
        border:triggered
            ?Border.all(color:Colors.orange.shade300)
            :null,
      ),
      child:Row(
        children:
        [
          Icon(
            triggered?Icons.stop_circle_outlined:Icons.arrow_right_rounded,
            color:triggered
                ?Colors.orange.shade600
                :colorScheme.onSurfaceVariant,
            size:20,
          ),
          const SizedBox(width:8),
          Text('Received: ',
              style:TextStyle(
                  fontSize:12,color:colorScheme.onSurfaceVariant)),
          Text('+${event.value}',
              style:TextStyle(
                  fontSize:14,
                  fontWeight:FontWeight.bold,
                  color:colorScheme.primary)),
          const Spacer(),
          Text('Sum = ${event.runningSum}',
              style:TextStyle(
                  fontSize:13,
                  fontWeight:FontWeight.w600,
                  color:triggered
                      ?Colors.orange.shade700
                      :colorScheme.onSurface)),
        ],
      ),
    );
  }
}
class _StatusBadge extends StatelessWidget
{
  final String label;
  final Color color;
  const _StatusBadge({required this.label,required this.color});
  @override
  Widget build(BuildContext context)
  {
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
      decoration:BoxDecoration(
        color:color.withOpacity(0.15),
        borderRadius:BorderRadius.circular(20),
        border:Border.all(color:color.withOpacity(0.3)),
      ),
      child:Text(label,
          style:TextStyle(
              fontSize:12,
              fontWeight:FontWeight.w600,
              color:color)),
    );
  }
}