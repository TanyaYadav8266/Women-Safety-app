import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: MentalHealthChat(),
  ));
}

class MentalHealthChat extends StatefulWidget {
  const MentalHealthChat({super.key});

  @override
  State<MentalHealthChat> createState() => _MentalHealthChatState();
}

class _MentalHealthChatState extends State<MentalHealthChat> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isBotTyping = false;

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isUser: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    
    _getBotResponse(text);
  }

  void _getBotResponse(String userMessage) {
    setState(() {
      _isBotTyping = true;
    });
    
    String response;
    String lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('depress') || lowerMessage.contains('sad')) {
      response = "I'm sorry you're feeling this way. It's important to remember that you're not alone. "
          "Would you like to talk more about what's been bothering you?";
    } 
    else if (lowerMessage.contains('anxious') || lowerMessage.contains('worry')) {
      response = "Anxiety can be really challenging. Try taking some deep breaths with me: "
          "Breathe in for 4 seconds, hold for 4 seconds, exhale for 6 seconds. "
          "Would you like to try this together?";
    }
    else if (lowerMessage.contains('stress') || lowerMessage.contains('overwhelm')) {
      response = "Stress can feel overwhelming at times. Sometimes breaking things down "
          "into smaller steps can help. Would you like to share what's causing you stress?";
    }
    else if (lowerMessage.contains('help') || lowerMessage.contains('emergency')) {
      response = "If you're in immediate distress, please reach out to a crisis hotline. "
          "In the US, you can call or text 988 for the Suicide & Crisis Lifeline. "
          "You're not alone, and help is available.";
    }
    else if (lowerMessage.contains('thank') || lowerMessage.contains('appreciate')) {
      response = "You're very welcome. I'm here to support you whenever you need. "
          "Remember that reaching out is a sign of strength, not weakness.";
    }
    else {
      response = "I hear you. It sounds like you're going through a tough time. "
          "Would you like to share more about how you're feeling?";
    }
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.insert(0, ChatMessage(
          text: response,
          isUser: false,
        ));
        _isBotTyping = false;
      });
    });
  }

  Widget _buildQuickReplies() {
    List<String> quickReplies = [
      "I'm feeling anxious",
      "I'm feeling depressed",
      "I need coping strategies",
      "I need emergency help"
    ];
    
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: quickReplies.map((reply) {
        return ActionChip(
          label: Text(reply),
          onPressed: () {
            _handleSubmitted(reply);
          },
          backgroundColor: Colors.purple[50],
        );
      }).toList(),
    );
  }

  void _showResources(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mental Health Resources'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResourceItem(
                "Crisis Text Line",
                "Text HOME to 741741 (US)",
                Icons.phone
              ),
              _buildResourceItem(
                "Suicide Prevention Lifeline",
                "Call 988 (US)",
                Icons.phone
              ),
              _buildResourceItem(
                "NAMI Helpline",
                "1-800-950-NAMI (6264)",
                Icons.phone
              ),
              _buildResourceItem(
                "Find a Therapist",
                "psychologytoday.com",
                Icons.search
              ),
              _buildResourceItem(
                "Mindfulness Exercises",
                "headspace.com",
                Icons.self_improvement
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildTypingIndicator() {
    return _isBotTyping 
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    child: Icon(Icons.psychology),
                    backgroundColor: Colors.purple,
                  ),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Bot',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 5),
                      TypingIndicator(),
                    ],
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildTextComposer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: _buildQuickReplies(),
        ),
        IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _handleSubmitted,
                    decoration: const InputDecoration.collapsed(
                      hintText: "Share how you're feeling...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Note: This chatbot provides support but is not a substitute for professional help.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Support'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showResources(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (_, int index) => _messages[index],
                  ),
                ),
                _buildTypingIndicator(),
              ],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              child: isUser 
                  ? const Text('You') 
                  : const Icon(Icons.psychology),
              backgroundColor: isUser ? Colors.blue : Colors.purple,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Support Bot',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.blue : Colors.purple,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    _animations = List.generate(3, (index) {
      return Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        const SizedBox(width: 4),
        _buildDot(1),
        const SizedBox(width: 4),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animations[index].value,
          child: child,
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}