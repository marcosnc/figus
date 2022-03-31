// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.7 <0.9.0;

interface IPublicityManager {

  struct Publicity {    
    uint256 lastPrice; // 32 B // Slot 1
    uint64 fee; // 8 B // Slot 2
    address owner; // 20 B // Slot 2
    address lastPublisher; // 20 B // Slot 3
    string text; // Depende
    string img; // Depende
  }
  
  // Views
  function getPublicity(uint256 publicityId) external view returns (Publicity memory publicity);

  // Modifies state
  function createPublicity(string calldata text, string calldata img, uint256 initialPrice, uint64 fee) external returns (uint256 publicityId);  
  function buyoutPublicity(uint256 publicityId, string calldata newText, string calldata newImg) external payable;
  function cancelPublicity(uint256 publicityId) external;

}

contract PublicityManager is IPublicityManager {

  mapping(uint256 => Publicity) internal _publicity;
  uint256 internal _publicityCounter;

  function getPublicity(uint256 publicityId) external view returns (Publicity memory) {
    return _publicity[publicityId];
  }

  function createPublicity(string calldata text, string calldata img, uint256 initialPrice, uint64 fee) external returns (uint256 publicityId) {
    require(initialPrice > fee, 'Initial price must be more than fee');
    publicityId = ++_publicityCounter;
    _publicity[publicityId] = Publicity({
      text: text,
      img: img,
      lastPrice: initialPrice,
      fee: fee,
      owner: msg.sender,
      lastPublisher: address(0)
    });
  }

  function buyoutPublicity(uint256 publicityId, string calldata newText, string calldata newImg) external payable {
    // Checks
    require(bytes(newText).length > 0, 'Empty text');
    require(bytes(newImg).length > 0, 'Empty imag');
    Publicity memory _pub = _publicity[publicityId];
    require(_pub.owner != address(0), 'Publicity does not exist');
    require(msg.value > _pub.lastPrice, 'Did not pay enough');

    // Effects
    _publicity[publicityId].lastPrice = msg.value;
    _publicity[publicityId].lastPublisher = msg.sender;
    _publicity[publicityId].text = newText;
    _publicity[publicityId].img = newImg;
    
    // Interactions
    // Devolver la plata al anterior
    if (_pub.lastPublisher != address(0)) {
      payable(_pub.lastPublisher).transfer(_pub.lastPrice - _pub.fee);
    }

    // Cobrar fee al que está pagando ahora
    payable(_pub.owner).transfer(_pub.fee);
  }

  function cancelPublicity(uint256 publicityId) external {
    // Checks
    Publicity memory _pub = _publicity[publicityId];
    require(msg.sender == _pub.owner, 'Only owner can cancel publicity');

    // Effects
    delete _publicity[publicityId];

    // Interactions
    // Devolver la plata al anterior
    if (_pub.lastPublisher != address(0)) {
      payable(_pub.lastPublisher).transfer(_pub.lastPrice - _pub.fee);
    }
  }
}
