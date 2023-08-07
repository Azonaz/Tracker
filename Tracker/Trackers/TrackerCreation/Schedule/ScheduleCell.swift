import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func changeSwitch (_ cell: ScheduleCell, isOn: Bool)
}

class ScheduleCell: UITableViewCell {
    
    static let reuseIdentifier = "ScheduleCell"
    weak var delegate: ScheduleCellDelegate?

    
    lazy var switchDay: UISwitch = {
        let switchDay = UISwitch()
        switchDay.tintColor = .ypWhite
        switchDay.onTintColor = .ypBlue
        switchDay.translatesAutoresizingMaskIntoConstraints = false
        return switchDay
    } ()
    
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createView()
        selectionStyle = .none
        switchDay.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func createView() {
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.textColor = .ypBlack
        contentView.addSubview(switchDay)
        NSLayoutConstraint.activate([
            switchDay.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchDay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func changeSwitch(_ sender: UISwitch) {
        delegate?.changeSwitch(self, isOn: sender.isOn)
    }
   
}
    

