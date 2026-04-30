import 'package:flutter/material.dart';
class AsyncScreen extends StatefulWidget
{
  const AsyncScreen({super.key});
  @override
  State<AsyncScreen> createState()=>_AsyncScreenState();
}
class _AsyncScreenState extends State<AsyncScreen>
    with SingleTickerProviderStateMixin
{
  _Status _status=_Status.idle;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  @override
  void initState()
  {
    super.initState();
    _pulseController=AnimationController(
      vsync:this,
      duration:const Duration(milliseconds:900),
    )..repeat(reverse:true);
    _pulseAnimation=Tween<double>(begin:0.85,end:1.0).animate(
      CurvedAnimation(parent:_pulseController,curve:Curves.easeInOut),
    );
  }
  @override
  void dispose()
  {
    _pulseController.dispose();
    super.dispose();
  }
  Future<void> _loadUser() async
  {
    setState(()=>_status=_Status.loading);
    await Future.delayed(const Duration(seconds:3));
    if(mounted)
    {
      setState(()=>_status=_Status.success);
    }
  }
  void _reset()=>setState(()=>_status=_Status.idle);
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return Scaffold(
      appBar:AppBar(
        title:const Text('Exercise 4 — Async Programming'),
        backgroundColor:colorScheme.surfaceContainer,
      ),
      body:Center(
        child:Padding(
          padding:const EdgeInsets.all(32),
          child:Column(
            mainAxisSize:MainAxisSize.min,
            children:
            [
              _buildStatusCard(context),
              const SizedBox(height:40),
              _buildControls(context),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStatusCard(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration:const Duration(milliseconds:400),
      switchInCurve:Curves.easeOut,
      switchOutCurve:Curves.easeIn,
      child:switch (_status)
      {
        _Status.idle=>_StatusCard(
          key:const ValueKey('idle'),
          icon:Icons.person_outline,
          iconColor:colorScheme.onSurfaceVariant,
          backgroundColor:colorScheme.surfaceContainer,
          title:'Ready',
          subtitle:'Press "Start Loading" to begin the async task.',
        ),
        _Status.loading=>ScaleTransition(
          key:const ValueKey('loading'),
          scale:_pulseAnimation,
          child:_StatusCard(
            icon:Icons.hourglass_top_rounded,
            iconColor:colorScheme.primary,
            backgroundColor:colorScheme.primaryContainer.withOpacity(0.5),
            title:'Loading user...',
            subtitle:'Please wait — fetching user data asynchronously.',
            showSpinner:true,
          ),
        ),
        _Status.success=>_StatusCard(
          key:const ValueKey('success'),
          icon:Icons.check_circle_rounded,
          iconColor:Colors.green.shade600,
          backgroundColor:Colors.green.shade50,
          title:'User loaded successfully!',
          subtitle:'The async operation completed after 3 seconds.',
        ),
      },
    );
  }
  Widget _buildControls(BuildContext context)
  {
    return switch (_status)
    {
      _Status.idle=>FilledButton.icon(
        onPressed:_loadUser,
        icon:const Icon(Icons.play_arrow_rounded),
        label:const Text('Start Loading'),
        style:FilledButton.styleFrom(
          padding:const EdgeInsets.symmetric(horizontal:28,vertical:14),
        ),
      ),
      _Status.loading=>OutlinedButton.icon(
        onPressed:null,
        icon:const SizedBox(
          width:16,
          height:16,
          child:CircularProgressIndicator(strokeWidth:2),
        ),
        label:const Text('Loading...'),
        style:OutlinedButton.styleFrom(
          padding:const EdgeInsets.symmetric(horizontal:28,vertical:14),
        ),
      ),
      _Status.success=>FilledButton.icon(
        onPressed:_reset,
        icon:const Icon(Icons.refresh_rounded),
        label:const Text('Run Again'),
        style:FilledButton.styleFrom(
          padding:const EdgeInsets.symmetric(horizontal:28,vertical:14),
          backgroundColor:Colors.green.shade600,
        ),
      ),
    };
  }
}
enum _Status
{
  idle,loading,success
}
class _StatusCard extends StatelessWidget
{
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final bool showSpinner;
  const _StatusCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    this.showSpinner = false,
  });
  @override
  Widget build(BuildContext context)
  {
    return Container(
      width:double.infinity,
      padding:const EdgeInsets.all(32),
      decoration:BoxDecoration(
        color:backgroundColor,
        borderRadius:BorderRadius.circular(24),
        boxShadow:
        [
          BoxShadow(
            color:Colors.black.withOpacity(0.06),
            blurRadius:20,
            offset:const Offset(0,6),
          ),
        ],
      ),
      child:Column(
        mainAxisSize:MainAxisSize.min,
        children:
        [
          Icon(icon,size:64,color:iconColor),
          const SizedBox(height:20),
          Text(
            title,
            style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold),
            textAlign:TextAlign.center,
          ),
          const SizedBox(height:8),
          Text(
            subtitle,
            style:TextStyle(
              fontSize:13,
              color:Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign:TextAlign.center,
          ),
          if(showSpinner) ...
          [
            const SizedBox(height:20),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
