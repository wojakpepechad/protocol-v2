/* Generated by ts-generator ver. 0.0.8 */
/* tslint:disable */

import {Signer} from 'ethers';
import {Provider, TransactionRequest} from '@ethersproject/providers';
import {Contract, ContractFactory, Overrides} from '@ethersproject/contracts';

import {WalletBalanceProvider} from './WalletBalanceProvider';

export class WalletBalanceProviderFactory extends ContractFactory {
  constructor(signer?: Signer) {
    super(_abi, _bytecode, signer);
  }

  deploy(_provider: string, overrides?: Overrides): Promise<WalletBalanceProvider> {
    return super.deploy(_provider, overrides || {}) as Promise<WalletBalanceProvider>;
  }
  getDeployTransaction(_provider: string, overrides?: Overrides): TransactionRequest {
    return super.getDeployTransaction(_provider, overrides || {});
  }
  attach(address: string): WalletBalanceProvider {
    return super.attach(address) as WalletBalanceProvider;
  }
  connect(signer: Signer): WalletBalanceProviderFactory {
    return super.connect(signer) as WalletBalanceProviderFactory;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): WalletBalanceProvider {
    return new Contract(address, _abi, signerOrProvider) as WalletBalanceProvider;
  }
}

const _abi = [
  {
    inputs: [
      {
        internalType: 'contract LendingPoolAddressesProvider',
        name: '_provider',
        type: 'address',
      },
    ],
    stateMutability: 'nonpayable',
    type: 'constructor',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: '_user',
        type: 'address',
      },
      {
        internalType: 'address',
        name: '_token',
        type: 'address',
      },
    ],
    name: 'balanceOf',
    outputs: [
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address[]',
        name: '_users',
        type: 'address[]',
      },
      {
        internalType: 'address[]',
        name: '_tokens',
        type: 'address[]',
      },
    ],
    name: 'batchBalanceOf',
    outputs: [
      {
        internalType: 'uint256[]',
        name: '',
        type: 'uint256[]',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: '_user',
        type: 'address',
      },
    ],
    name: 'getUserWalletBalances',
    outputs: [
      {
        internalType: 'address[]',
        name: '',
        type: 'address[]',
      },
      {
        internalType: 'uint256[]',
        name: '',
        type: 'uint256[]',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    stateMutability: 'payable',
    type: 'receive',
  },
];

const _bytecode =
  '0x608060405234801561001057600080fd5b506040516108bc3803806108bc8339818101604052602081101561003357600080fd5b5051600080546001600160a01b039092166001600160a01b0319909216919091179055610857806100656000396000f3fe6080604052600436106100385760003560e01c80639e3c930914610083578063b59b28ef1461014f578063f7888aec146102d35761007e565b3661007e5761004633610320565b61007c576040805162461bcd60e51b8152602060048201526002602482015261191960f11b604482015290519081900360640190fd5b005b600080fd5b34801561008f57600080fd5b506100b6600480360360208110156100a657600080fd5b50356001600160a01b031661035c565b604051808060200180602001838103835285818151815260200191508051906020019060200280838360005b838110156100fa5781810151838201526020016100e2565b50505050905001838103825284818151815260200191508051906020019060200280838360005b83811015610139578181015183820152602001610121565b5050505090500194505050505060405180910390f35b34801561015b57600080fd5b506102836004803603604081101561017257600080fd5b81019060208101813564010000000081111561018d57600080fd5b82018360208201111561019f57600080fd5b803590602001918460208302840111640100000000831117156101c157600080fd5b919080806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250929594936020810193503591505064010000000081111561021157600080fd5b82018360208201111561022357600080fd5b8035906020019184602083028401116401000000008311171561024557600080fd5b91908080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525092955061064d945050505050565b60408051602080825283518183015283519192839290830191858101910280838360005b838110156102bf5781810151838201526020016102a7565b505050509050019250505060405180910390f35b3480156102df57600080fd5b5061030e600480360360408110156102f657600080fd5b506001600160a01b0381358116916020013516610777565b60408051918252519081900360200190f35b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061035457508115155b949350505050565b60608060008060009054906101000a90046001600160a01b03166001600160a01b0316630261bf8b6040518163ffffffff1660e01b815260040160206040518083038186803b1580156103ae57600080fd5b505afa1580156103c2573d6000803e3d6000fd5b505050506040513d60208110156103d857600080fd5b505160408051630240bc6b60e21b815290519192506060916001600160a01b03841691630902f1ac916004808301926000929190829003018186803b15801561042057600080fd5b505afa158015610434573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052602081101561045d57600080fd5b810190808051604051939291908464010000000082111561047d57600080fd5b90830190602082018581111561049257600080fd5b82518660208202830111640100000000821117156104af57600080fd5b82525081516020918201928201910280838360005b838110156104dc5781810151838201526020016104c4565b5050505090500160405250505090506060815167ffffffffffffffff8111801561050557600080fd5b5060405190808252806020026020018201604052801561052f578160200160208202803683370190505b50905060005b8251811015610641576000846001600160a01b0316633e15014185848151811061055b57fe5b60200260200101516040518263ffffffff1660e01b815260040180826001600160a01b03166001600160a01b031681526020019150506101406040518083038186803b1580156105aa57600080fd5b505afa1580156105be573d6000803e3d6000fd5b505050506040513d6101408110156105d557600080fd5b5061010001519050806106025760008383815181106105f057fe5b60200260200101818152505050610639565b61061f8885848151811061061257fe5b6020026020010151610777565b83838151811061062b57fe5b602002602001018181525050505b600101610535565b50909350915050915091565b606080825184510267ffffffffffffffff8111801561066b57600080fd5b50604051908082528060200260200182016040528015610695578160200160208202803683370190505b50905060005b845181101561076d5760005b84518110156107645760008551830290506106dd8683815181106106c757fe5b60200260200101516001600160a01b0316610320565b61071e576040805162461bcd60e51b815260206004820152600d60248201526c24a72b20a624a22faa27a5a2a760991b604482015290519081900360640190fd5b61074187848151811061072d57fe5b602002602001015187848151811061061257fe5b848383018151811061074f57fe5b602002602001018181525050506001016106a7565b5060010161069b565b5090505b92915050565b600061078b826001600160a01b0316610320565b1561081957816001600160a01b03166370a08231846040518263ffffffff1660e01b815260040180826001600160a01b03166001600160a01b0316815260200191505060206040518083038186803b1580156107e657600080fd5b505afa1580156107fa573d6000803e3d6000fd5b505050506040513d602081101561081057600080fd5b50519050610771565b50600061077156fea26469706673582212205c02525d7f27487daf15c9c999fd0681611813fb940b7514fa98150dfb5730ab64736f6c63430006080033';
