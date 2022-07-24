%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from cairo_contracts.src.openzeppelin.token.erc721.library import ERC721

#
# Events
#
@event
func DataUpdate(token_id : Uint256, type : felt, data : felt):
end

@event
func VerifiedData(token_id : Uint256, type : felt, data : felt, verifier : felt):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ERC721.initializer('Starknet.id', 'ID')
    return ()
end

#
# Storage Vars
#

@storage_var
func identity_data_storage(token_id : Uint256, type : felt) -> (data : felt):
end

@storage_var
func is_valid_data_storage(tokenid : Uint256, type : felt, data : felt, address : felt) -> (
    rep : felt
):
end

#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC721.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC721.symbol()
    return (symbol)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt
) -> (balance : Uint256):
    let (balance : Uint256) = ERC721.balance_of(owner)
    return (balance)
end

@view
func ownerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (owner : felt):
    let (owner : felt) = ERC721.owner_of(token_id)
    return (owner)
end

@view
func getApproved{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (approved : felt):
    let (approved : felt) = ERC721.get_approved(token_id)
    return (approved)
end

@view
func isApprovedForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, operator : felt
) -> (is_approved : felt):
    let (is_approved : felt) = ERC721.is_approved_for_all(owner, operator)
    return (is_approved)
end

#
# STARKNET ID specific
#
@view
func get_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, type : felt
) -> (data : felt):
    let (data : felt) = identity_data_storage.read(token_id, type)
    return (data)
end

@view
func get_valid_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, type : felt, address : felt
) -> (data : felt):
    let (data : felt) = identity_data_storage.read(token_id, type)
    let (is_valid : felt) = is_valid_data_storage.read(token_id, type, data, address)
    if is_valid == 1:
        return (data)
    else:
        return (0)
    end
end

@view
func is_valid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, type : felt, address : felt
) -> (is_valid : felt):
    let (data : felt) = identity_data_storage.read(token_id, type)
    let (is_valid : felt) = is_valid_data_storage.read(token_id, type, data, address)
    return (is_valid)
end

#
# Externals
#

@external
func approve{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    to : felt, token_id : Uint256
):
    ERC721.approve(to, token_id)
    return ()
end

@external
func setApprovalForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    operator : felt, approved : felt
):
    ERC721.set_approval_for_all(operator, approved)
    return ()
end

@external
func transferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    _from : felt, to : felt, token_id : Uint256
):
    ERC721.transfer_from(_from, to, token_id)
    return ()
end

@external
func safeTransferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    _from : felt, to : felt, token_id : Uint256, data_len : felt, data : felt*
):
    ERC721.safe_transfer_from(_from, to, token_id, data_len, data)
    return ()
end

#
# STARKNET ID specific
#
@external
func set_data{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256, type : felt, data : felt
):
    let (owner) = ERC721.owner_of(token_id)
    let (caller) = get_caller_address()
    assert owner = caller
    DataUpdate.emit(token_id, type, data)
    identity_data_storage.write(token_id, type, data)
    return ()
end

@external
func confirm_validity{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256, type : felt, data : felt
):
    let (address) = get_caller_address()
    VerifiedData.emit(token_id, type, data, address)
    is_valid_data_storage.write(token_id, type, data, address, 1)
    return ()
end

@external
func mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(tokenId : Uint256):
    let (to) = get_caller_address()
    ERC721._mint(to, tokenId)
    return ()
end
