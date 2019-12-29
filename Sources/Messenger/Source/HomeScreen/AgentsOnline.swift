//
//  AgentsOnline.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 14/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit
import PINCacheTexture

class AgentsOnlineNode: ASCellNode {

	let backgroundNode = ASDisplayNode { () -> UIView in
		let effect = UIBlurEffect(style: .extraLight)
		let vibrancyEffect = UIVibrancyEffect(blurEffect: effect)
		
		let visualEffectView = UIVisualEffectView(effect: effect)
		let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
		vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		visualEffectView.backgroundColor = .clear
		visualEffectView.contentView.addSubview(vibrancyView)
		return visualEffectView
	}
	
	let agents: [UserMinimal]
	var agentAvatars: [ASNetworkImageNode] = []
	let headerNode = ConversationHeaderCell(headingText: "WE ARE HERE TO HELP", subheadingText: "")
	let onlineStatusText = ASTextNode()
	let container = ASDisplayNode()
	
	init(agents: [UserMinimal]) {
		self.agents = agents
		super.init()
		self.backgroundColor = .clear
		self.selectionStyle = .none
		
		let agentsToShow = agents.filter{ $0.firstName != nil }
			
		self.agentAvatars = [agentsToShow.first, agentsToShow.second, agentsToShow.third].flatMap{$0}.map {
			let node = ASNetworkImageNode()
			node.style.height = ASDimensionMake(50)
			node.style.width = ASDimensionMake(50)
			node.clipsToBounds = true
			node.layer.cornerRadius = 25.0
//			node.url = $0.avatar
			node.setImageVM(.url($0.avatar))
			
			return node
		}
		
		let onlineStatusString: String = {
			let agentFirstNames = agentsToShow.flatMap{ $0.firstName }
			if agentFirstNames.count > 2 {
				return "\(agentFirstNames.first!), \(agentFirstNames.second!) and \(agentFirstNames.third!) are online"
			} else if agentFirstNames.count == 2 {
				return "\(agentFirstNames.first!) and \(agentFirstNames.second!) are online"
			} else if agentFirstNames.count == 1 {
				return "\(agentFirstNames.first!) is online"
			} else {
				return ""
			}
		}()
		
		onlineStatusText.attributedText = NSAttributedString(string: onlineStatusString, attributes: KayakoLightStyle.HomescreenAttributes.widgetSubHeadingStyle)
		
		container.addSubnode(backgroundNode)
		container.addSubnode(headerNode)
		container.addSubnode(onlineStatusText)
		self.addSubnode(container)
		
		container.clipsToBounds = true
		container.layer.cornerRadius = 6.0
		
		for node in self.agentAvatars {
			container.addSubnode(node)
		}
		
		container.layoutSpecBlock = {
			[weak self] _,size in
			guard let strongSelf = self else { return ASLayoutSpec() }
			var elements: [ASLayoutElement] = [strongSelf.headerNode]
			strongSelf.headerNode.style.spacingAfter = 6.0
			let avatarStack = ASStackLayoutSpec(direction: .horizontal, spacing: 9, justifyContent: .start, alignItems: .center, children: strongSelf.agentAvatars)
            let avatarStackInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 9), child: avatarStack)
			elements.append(avatarStackInset)
            let onlineStatusInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 18, bottom: 9, right: 9), child: strongSelf.onlineStatusText)
			elements.append(onlineStatusInset)
			let stack = ASStackLayoutSpec(direction: .vertical, spacing: 7.0, justifyContent: .start, alignItems: .stretch, children: elements)
			
			let bg =  ASBackgroundLayoutSpec(child: stack, background: strongSelf.backgroundNode)
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: bg)
		}
		self.transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
	}
	
	open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let stack = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .start, alignItems: .stretch, children: [container])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0), child: stack)
	}
}
